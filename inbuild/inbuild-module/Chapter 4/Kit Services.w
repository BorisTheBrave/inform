[Kits::] Kits.

A kit is a combination of Inter code with an Inform 7 extension.

@h Genre definition.

=
typedef struct inform_kit {
	struct inbuild_copy *as_copy;
	struct text_stream *name;
	struct text_stream *attachment_point;
	struct text_stream *early_source;
	struct linked_list *ittt; /* of |inform_kit_ittt| */
	struct linked_list *kind_definitions; /* of |text_stream| */
	struct linked_list *extensions; /* of |text_stream| */
	struct linked_list *activations; /* of |element_activation| */
	struct text_stream *index_template;
	struct inbuild_version_number version;
	int defines_Main;
	int supports_inform_language;
	int priority;
	MEMORY_MANAGEMENT
} inform_kit;

typedef struct inform_kit_ittt {
	struct text_stream *if_name;
	int if_included;
	struct text_stream *then_name;
	MEMORY_MANAGEMENT
} inform_kit_ittt;

typedef struct element_activation {
	struct text_stream *element_name;
	int activate;
	MEMORY_MANAGEMENT
} element_activation;

pathname *Kits::find(text_stream *name, linked_list *nest_list) {
	inbuild_nest *N;
	LOOP_OVER_LINKED_LIST(N, inbuild_nest, nest_list) {
		pathname *P = KitManager::path_within_nest(N);
		P = Pathnames::subfolder(P, name);
		filename *F = Filenames::in_folder(P, I"kit_metadata.txt");
		if (TextFiles::exists(F)) return P;
	}
	return NULL;
}

inform_kit *Kits::new_ik(text_stream *name, pathname *P) {
	inform_kit *K = CREATE(inform_kit);
	K->as_copy = NULL;
	K->name = Str::duplicate(name);
	K->attachment_point = Str::new();
	WRITE_TO(K->attachment_point, "/main/%S", name);
	K->early_source = NULL;
	K->priority = 10;
	K->ittt = NEW_LINKED_LIST(inform_kit_ittt);
	K->kind_definitions = NEW_LINKED_LIST(text_stream);
	K->extensions = NEW_LINKED_LIST(text_stream);
	K->activations = NEW_LINKED_LIST(element_activation);
	K->defines_Main = FALSE;
	K->supports_inform_language = FALSE;
	K->index_template = NULL;
	K->version = VersionNumbers::null();
	
	filename *F = Filenames::in_folder(P, I"kit_metadata.txt");
	TextFiles::read(F, FALSE,
		NULL, FALSE, Kits::read_metadata, NULL, (void *) K);
	return K;
}

inform_kit *Kits::load(text_stream *name, linked_list *nest_list) {
	pathname *P = Kits::find(name, nest_list);
	if (P == NULL) Errors::fatal_with_text("cannot find kit", name);
	inbuild_copy *C = KitManager::new_copy(name, P);
	if (C->vertex == NULL) KitManager::build_vertex(C);
	return KitManager::from_copy(C);
}

void Kits::dependency(inform_kit *K, text_stream *if_text, int inc, text_stream *then_text) {
	inform_kit_ittt *ITTT = CREATE(inform_kit_ittt);
	ITTT->if_name = Str::duplicate(if_text);
	ITTT->if_included = inc;
	ITTT->then_name = Str::duplicate(then_text);
	ADD_TO_LINKED_LIST(ITTT, inform_kit_ittt, K->ittt);
}

void Kits::activation(inform_kit *K, text_stream *name, int act) {
	element_activation *EA = CREATE(element_activation);
	EA->element_name = Str::duplicate(name);
	EA->activate = act;
	ADD_TO_LINKED_LIST(EA, element_activation, K->activations);
}

void Kits::read_metadata(text_stream *text, text_file_position *tfp, void *state) {
	inform_kit *K = (inform_kit *) state;
	match_results mr = Regexp::create_mr();
	if ((Str::is_whitespace(text)) || (Regexp::match(&mr, text, L" *#%c*"))) {
		;
	} else if (Regexp::match(&mr, text, L"version: (%C+)")) {
		K->version = VersionNumbers::from_text(mr.exp[0]);
	} else if (Regexp::match(&mr, text, L"defines Main: yes")) {
		K->defines_Main = TRUE;
	} else if (Regexp::match(&mr, text, L"defines Main: no")) {
		K->defines_Main = FALSE;
	} else if (Regexp::match(&mr, text, L"natural language: yes")) {
		K->supports_inform_language = TRUE;
	} else if (Regexp::match(&mr, text, L"natural language: no")) {
		K->supports_inform_language = FALSE;
	} else if (Regexp::match(&mr, text, L"insert: (%c*)")) {
		K->early_source = Str::duplicate(mr.exp[0]);
		WRITE_TO(K->early_source, "\n\n");
	} else if (Regexp::match(&mr, text, L"priority: (%d*)")) {
		K->priority = Str::atoi(mr.exp[0], 0);
	} else if (Regexp::match(&mr, text, L"kinds: (%C+)")) {
		ADD_TO_LINKED_LIST(Str::duplicate(mr.exp[0]), text_stream, K->kind_definitions);
	} else if (Regexp::match(&mr, text, L"extension: (%c+)")) {
		ADD_TO_LINKED_LIST(Str::duplicate(mr.exp[0]), text_stream, K->extensions);
	} else if (Regexp::match(&mr, text, L"activate: (%c+)")) {
		Kits::activation(K, mr.exp[0], TRUE);
	} else if (Regexp::match(&mr, text, L"deactivate: (%c+)")) {
		Kits::activation(K, mr.exp[0], FALSE);
	} else if (Regexp::match(&mr, text, L"dependency: if (%C+) then (%C+)")) {
		Kits::dependency(K, mr.exp[0], TRUE, mr.exp[1]);
	} else if (Regexp::match(&mr, text, L"dependency: if not (%C+) then (%C+)")) {
		Kits::dependency(K, mr.exp[0], FALSE, mr.exp[1]);
	} else if (Regexp::match(&mr, text, L"index from: (%c*)")) {
		K->index_template = Str::duplicate(mr.exp[0]);
	} else {
		Errors::in_text_file("illegible line in kit metadata file", tfp);
		WRITE_TO(STDERR, "'%S'\n", text);
	}
	Regexp::dispose_of(&mr);
}

int Kits::perform_ittt(inform_kit *K, inform_project *project, int parity) {
	int changes_made = FALSE;
	inform_kit_ittt *ITTT;
	LOOP_OVER_LINKED_LIST(ITTT, inform_kit_ittt, K->ittt)
		if ((ITTT->if_included == parity) &&
			(Projects::uses_kit(project, ITTT->then_name) == FALSE) &&
			(Projects::uses_kit(project, ITTT->if_name) == ITTT->if_included)) {
			Projects::add_kit_dependency(project, ITTT->then_name);
			changes_made = TRUE;
		}
	return changes_made;
}

#ifdef CORE_MODULE
void Kits::load_types(inform_kit *K) {
	text_stream *segment;
	LOOP_OVER_LINKED_LIST(segment, text_stream, K->kind_definitions) {
		pathname *P = Pathnames::subfolder(K->as_copy->location_if_path, I"kinds");
		filename *F = Filenames::in_folder(P, segment);
		LOG("Loading kinds definitions from %f\n", F);
		I6T::interpret_kindt(F);
	}
}
#endif

#ifdef CORE_MODULE
void Kits::activate_plugins(inform_kit *K) {
	element_activation *EA;
	LOOP_OVER_LINKED_LIST(EA, element_activation, K->activations) {
		int S = Plugins::Manage::parse(EA->element_name);
		if (S == -1)
			Problems::Issue::sentence_problem(_p_(Untestable),
				"one of the Inform kits made reference to a language segment which does not exist",
				"which strongly suggests that Inform is not properly installed.");
		if (S >= 0) {
			if (EA->activate) Plugins::Manage::activate(S);
			else Plugins::Manage::deactivate(S);
		}
	}
}
#endif

void Kits::early_source_text(OUTPUT_STREAM, inform_kit *K) {
	text_stream *X;
	LOOP_OVER_LINKED_LIST(X, text_stream, K->extensions)
		WRITE("Include %S.\n\n", X);
	if (K->early_source) WRITE("%S\n\n", K->early_source);
}

int Kits::number_of_early_fed_sentences(inform_kit *K) {
	int N = 0;
	text_stream *X;
	LOOP_OVER_LINKED_LIST(X, text_stream, K->extensions) N++;
	if (K->early_source) N++;
	return N;
}

linked_list *Kits::inter_paths(void) {
	linked_list *inter_paths = NEW_LINKED_LIST(pathname);
	inbuild_nest *N;
	linked_list *L = Inbuild::nest_list();
	LOOP_OVER_LINKED_LIST(N, inbuild_nest, L)
		ADD_TO_LINKED_LIST(KitManager::path_within_nest(N), pathname, inter_paths);
	return inter_paths;
}