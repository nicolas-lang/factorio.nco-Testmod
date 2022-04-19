# Factorio Test Mod


### **introduction:**

- After the previous discussion with ... regarding object orientation in context of desync safety, I have spent some time refactoring my approach and ended up with this example.
- I would really appreciate some thoughts if this is what you meant with ..., also I am open for suggestions regarding possible improvements

### **use case:**

- the main focus is to create code with a very localized scope's
- the final mod will not "wrap"" many LuaEntities (expected <100) but has multiple layers of logic
- object orientation will help keeping the global control code simple while allowing localized 'hacks' around api limitations

### **assumptions:**

- perforemance is not part of the current considerations

-------------------------------------------------------------------------------