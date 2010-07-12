package org.farmcode.actLibrary.application.states
{
	import org.farmcode.actLibrary.application.states.states.RegExpAppState;

	public class AppStateConstants
	{
		public static const START_MATCHER:RegExp = /^\/?/;
		public static const START_REPLACE:String = "^/?";
		public static const END_MATCHER:RegExp = /\/?$/;
		public static const END_REPLACE:String = "/?$";
		
		public static const STAR_MATCHER:RegExp = /\*/g;
		public static const STAR_REPLACE:String = "(?P<"+RegExpAppState.STAR_PSUEDONYM+">.+?)";
		
		public static const LABEL_MATCHER:RegExp = /(?P<slash>\\|\/|^):(?P<name>[^ \\\/]+)/g;
		public static const LABEL_REPLACE:String = "$1(?P<$2>[^\\/\\\\]*)";
		
		public static const LABEL_RECON:String = "(?:\/|^):$name(?:\/|$)";
		public static const LABEL_RECON_REPLACE:String = "/$value/";
		
		
		public static const REGEXP_SAFE_MATCHER:RegExp = /([\[\]\^\\\/*+?().])/g;
		public static const REGEXP_SAFE_REPLACE:String = "\\$1";
	}
}