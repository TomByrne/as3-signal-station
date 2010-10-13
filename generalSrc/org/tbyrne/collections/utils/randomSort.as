package org.tbyrne.collections.utils
{
	/**
	 * Returns a random selected int (either -1,0 or 1). This is suitable
	 * for use with Array.sort.
	 */
	public function randomSort(element1: *, element2: *): int{
		var diff: int = 0;
		var result: Number = Math.random();
		if (result < 0.5)
		{
			diff = 1;
		}
		else if (result > 0.5)
		{
			diff = -1;
		}
		return diff;
	}
}