# Factorio Test Mod


After a stern talking to, regarding my initial (very naive) approach of object orientation in factorio-modding (especially in the  context of desync safety), I have spent some time refactoring my approach.

After integrating the suggestion to globalize my classes, I ended up with this example.

### use case:
- the main focus is to create code with very localized scope's
- the final mod will not "wrap"" many LuaEntities (expected <100) but has multiple layers of logic
- object orientation will help keeping the main-control-flow simple while allowing localized intricate 'hacks' around for example api limitations

### assumptions:
- perforemance is not part of the current considerations
- I really want to do this!
I would really appreciate some thoughts if this seems more reasonable than my 1st approach - also I am open for suggestions regarding possible improvements.
