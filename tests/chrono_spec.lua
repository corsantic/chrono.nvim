local converter = require('chrono.converter')
local chrono = require('chrono')

describe("timestamp converter", function()
  it("should handle valid epoch timestamp", function()
    local result = converter.convert_timestamp("1640995200") -- Jan 1, 2022
    assert.matches("2022%-01%-01", result)
  end)

  it("should handle millisecond timestamp", function()
    local result = converter.convert_timestamp("1640995200000") -- Jan 1, 2022 in ms
    assert.matches("2022%-01%-01", result)
  end)

  it("should handle microsecond timestamp", function()
    local result = converter.convert_timestamp("1640995200000000") -- Jan 1, 2022 in μs
    assert.matches("2022%-01%-01", result)
  end)

  it("should show error for non-numeric input", function()
    local result = converter.convert_timestamp("abc123")
    assert.equals("Selected text is not a valid number", result)
  end)

  it("should show error for negative numbers", function()
    local result = converter.convert_timestamp("-123456")
    assert.equals("Negative numbers are not supported", result)
  end)

  it("should show error for invalid timestamp range", function()
    local result = converter.convert_timestamp("99999999999999") -- Way too large
    assert.equals("Number doesn't appear to be a valid timestamp", result)
  end)

  it("should use custom date format", function()
    local result = converter.convert_timestamp("1640995200", "%d/%m/%Y")
    assert.matches("01/01/2022", result)
  end)
end)

describe("chrono configuration", function()
  it("should enable/disable functionality", function()
    chrono.disable()
    assert.is_false(chrono.config.enabled)

    chrono.enable()
    assert.is_true(chrono.config.enabled)

    chrono.toggle()
    assert.is_false(chrono.config.enabled)
  end)

  it("should accept custom configuration", function()
    chrono.setup({
      date_format = '%d/%m/%Y',
      convert_key = '<leader>tc'
    })

    assert.equals('%d/%m/%Y', chrono.config.date_format)
    assert.equals('<leader>tc', chrono.config.convert_key)
  end)
end)
