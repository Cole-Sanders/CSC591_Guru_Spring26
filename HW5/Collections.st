"Part B: Collections and blocks"

nums := #(1 2 3 4 5 6).

'original:' printNl.
nums printNl.

'do: (each item)' printNl.
nums do: [ :each | each printNl ].

'collect: (doubled)' printNl.
(nums collect: [ :each | each * 2 ]) printNl.

'select: (even only)' printNl.
(nums select: [ :each | each even ]) printNl.

'reject: (reject < 4)' printNl.
(nums reject: [ :each | each < 4 ]) printNl.

'inject:into: (sum)' printNl.
(nums inject: 0 into: [ :sum :each | sum + each ]) printNl.