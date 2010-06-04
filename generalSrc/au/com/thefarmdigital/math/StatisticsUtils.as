package au.com.thefarmdigital.math
{
	public class StatisticsUtils
	{
		public static function sum(items: Array, propName: String = null): Number
		{
			var total: Number = 0;
			for each (var item: * in items)
			{
				if (propName == null)
				{
					total += item;
				}
				else
				{
					total += item[propName];
				}
			}
			return total;
		}
		
		public static function average(items: Array, propName: String = null): Number
		{
			var ave: Number = 0;
			if (items.length > 0)
			{
				ave = StatisticsUtils.sum(items, propName) / items.length;
			}
			return ave;
		}
		
		public static function min(items: Array, propName: String = null): *
		{
			return StatisticsUtils.boundaryValue(items, propName, -1);
		}
		
		public static function max(items: Array, propName: String = null): *
		{
			return StatisticsUtils.boundaryValue(items, propName, 1);
		}
		
		protected static function boundaryValue(items: Array, propName: String = null, comparison: int = 1): *
		{
			var targetItem: * = null;
			var targetValue: Number = Number.MIN_VALUE * comparison;
			for each (var item: * in items)
			{
				var testValue: Number;
				if (propName == null)
				{
					testValue = item;
				}
				else
				{
					testValue = item[propName];
				}
				if ((testValue * comparison) > targetValue)
				{
					targetValue = testValue;
					targetItem = item;
				}
			}
			return targetItem;
		}
	}
}