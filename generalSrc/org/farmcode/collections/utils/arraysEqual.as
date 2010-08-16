package org.farmcode.collections.utils
{
	// TODO: Implement a flag for whether ordering is important
	// currently doesn't matter about the order
	public function arraysEqual(arr1: Array, arr2: Array): Boolean
	{
		var equal: Boolean = false;
		
		if (arr1 == arr2)
		{
			equal = true;
		}
		else if (arr1 != null && arr2 != null && arr1.length == arr2.length)
		{
			var arr1Check: Array = arr1.slice();
			var missingItem: Boolean = false;
			for (var i: uint = 0; i < arr2.length && !missingItem; ++i)
			{
				var testItem: * = arr2[i];
				var arr1CheckIndex: int = arr1Check.indexOf(testItem);
				if (arr1CheckIndex >= 0)
				{
					arr1Check.splice(arr1CheckIndex, 1);
				}
				else
				{
					missingItem = true;
				}
			}
			if (arr1Check.length == 0)
			{
				equal = true;
			}
		}
		
		return equal;
	}
}