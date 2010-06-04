package org.farmcode.display.progress
{
	public class ProgressLabelFormatter
	{
		public static const MESSAGE:String = "${m}";
		public static const PROGRESS:String = "${p}";
		public static const TOTAL:String = "${t}";
		public static const PERCENT:String = "${%}";
		public static const UNITS:String = "${u}";
		
		public static function format(labelFormat:String, message:String, progress:Number, total:Number, units:String):String
		{
			var ret:String = labelFormat;
			ret = ret.replace(PROGRESS,progress);
			ret = ret.replace(TOTAL,total);
			ret = ret.replace(PERCENT,Math.round((progress/total)*100));
			ret = ret.replace(UNITS,units);
			return ret;
		}
	}
}