## Run tests headles using minimal_init

```bash
  nvim --headless --noplugin -u tests/minimal_init.lua -c "lua require('plenary.test_harness').test_directory('tests/')" -c "qa!"
```
