package utils;

import utest.Assert;

import koui.utils.StringUtil;

class TestStringUtil extends utest.Test {
	function setup() {}

	function teardown() {}

	function testUnescape() {
		Assert.equals(StringUtil.unescape("te\"st"), "te\"st");
		Assert.equals(StringUtil.unescape("te\\\\st"), "te\\st");
		Assert.equals(StringUtil.unescape("te\\nst"), "te\nst");
		Assert.equals(StringUtil.unescape("te\\\\nst"), "te\\nst");

		Assert.raises(() -> {
			// Store in variable to prevent function call removal. Disabling
			// DCE does not work here...
			var output = StringUtil.unescape("te\\qst");
		}, String);
	}
}
