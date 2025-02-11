Adjectival Definitions.

All the built-in adjectives on Basic Inform, from even and odd (for numbers)
to symmetric (for relations).

@ See test case |BIP-Adjectives|.

=
Part Four - Adjectival Definitions

Section 1 - Miscellaneous Useful Adjectives

Definition: a number is even rather than odd if the remainder after dividing it by 2 is 0.
Definition: a number is positive if it is greater than zero.
Definition: a number is negative if it is less than zero.

Definition: a text is empty rather than non-empty if I6 routine
	"TEXT_TY_Empty" says so (it contains no characters).

Definition: a text is substituted rather than unsubstituted if I6 routine
	"TEXT_TY_IsSubstituted" says so (any square-bracketed text substitutions
	in it have been made).

Definition: a table name is empty rather than non-empty if the number of filled rows in it is 0.
Definition: a table name is full rather than non-full if the number of blank rows in it is 0.

Definition: a rulebook is empty rather than non-empty if I6 routine "RulebookEmpty" says so (it
	contains no rules, so that following it does nothing and makes no decision).

Definition: an activity is empty rather than non-empty if I6 routine "ActivityEmpty" says so (its
	before, for and after rulebooks are all empty).
Definition: an activity is going on if I6 routine "TestActivity" says so (one
	of its three rulebooks is currently being run).

Definition: a list of values is empty rather than non-empty if I6 routine
	"LIST_OF_TY_Empty" says so (it contains no entries).

Definition: a use option is active rather than inactive if I6 routine
	"TestUseOption" says so (it has been requested in the source text).

Definition: a verb is modal rather than non-modal if I6 routine "VerbIsModal"
	says so (it modifies the likelihood of another verb happening, rather than
	being meaningful itself).

Definition: a verb is meaningful rather than meaningless if I6 routine "VerbIsMeaningful"
	says so (it has a meaning in Inform as a relation, rather than existing only to be
	printed out).

@ See test case |BIP-RelationAdjectives-G|.

=
Section 2 - Adjectives for Relations

Definition: a relation is equivalence if I6 routine
	"RELATION_TY_EquivalenceAdjective" makes it so (it is an equivalence
	relation, that is, it relates in groups).

Definition: a relation is symmetric if I6 routine
	"RELATION_TY_SymmetricAdjective" makes it so (it is a symmetric relation,
	that is, it's always true that X is related to Y if and only if Y is
	related to X).

Definition: a relation is one-to-one if I6 routine
	"RELATION_TY_OToOAdjective" makes it so (it is a one-to-one relation,
	that is, any given X can relate to only one Y, and vice versa).

Definition: a relation is one-to-various if I6 routine
	"RELATION_TY_OToVAdjective" makes it so (it is a one-to-various
	relation, that is, any given Y has only one X such that X relates to Y).

Definition: a relation is various-to-one if I6 routine
	"RELATION_TY_VToOAdjective" makes it so (it is a various-to-one
	relation, that is, any given X relates to only one Y).

Definition: a relation is various-to-various if I6 routine
	"RELATION_TY_VToVAdjective" makes it so (it is a
	various-to-various relation, that is, there are no limitations on how many
	X can relate to a given Y, or vice versa).

Definition: a relation is empty rather than non-empty if I6 routine
	"RELATION_TY_Empty" makes it so (it does not relate any values, that is,
	R(x,y) is false for all x and y).

@ See test case |BIP-RealAdjectives-G|.

=
Section 3 - Adjectives for Real Numbers (not for Z-machine)

Definition: a real number is positive if it is greater than zero.
Definition: a real number is negative if it is less than zero.
Definition: a real number is infinite rather than finite if it is plus infinity
	or it is minus infinity.
Definition: a real number is nonexistent rather than existent if I6 routine
	"REAL_NUMBER_TY_Nan" says so (it results from an impossible calculation,
	like the square root of minus one).

@ And so, at last...

=
Basic Inform ends here.

@ ...except that this is not quite true, because like most extensions it
then quotes some documentation for Inform to weave into index pages: though
here it's more of a polite refusal than a manual, since the entire system
documentation is really the description of what was defined in this
extension.

=
---- DOCUMENTATION ----

Unlike other extensions, Basic Inform is compulsorily included with every
project. It defines the phrases, kinds and relations which are basic to
Inform, and which are described throughout the documentation.
