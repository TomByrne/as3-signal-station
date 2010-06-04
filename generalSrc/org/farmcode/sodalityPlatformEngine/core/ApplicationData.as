package org.farmcode.sodalityPlatformEngine.core
{
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	import org.farmcode.sodality.advisors.IAdvisor;
	import org.farmcode.sodalityPlatformEngine.display.DisplayLayer;
	import org.farmcode.sodalityPlatformEngine.structs.WorldDef;
	
	public class ApplicationData implements IApplicationData
	{
		[Property(toString="true",clonable="true")]
		public var data: Array;
		
		
		[Property(toString="true",clonable="true")]
		public function get advisors():Array{
			return _advisors;
		}
		public function set advisors(value:Array):void{
			_advisors = value;
		}
		
		[Property(toString="true",clonable="true")]
		public function get initialAdvice():Array{
			return _initialAdvice;
		}
		public function set initialAdvice(value:Array):void{
			_initialAdvice = value;
		}
		
		[Property(toString="true",clonable="true")]
		public function get minAppSize():Rectangle{
			return _minAppSize;
		}
		public function set minAppSize(value:Rectangle):void{
			_minAppSize = value;
		}
		
		[Property(toString="true",clonable="true")]
		public function get scaleBelowMin():Boolean{
			return _scaleBelowMin;
		}
		public function set scaleBelowMin(value:Boolean):void{
			_scaleBelowMin = value;
		}
		
		[Property(toString="true",clonable="true")]
		public function get rootDisplay():DisplayLayer{
			return _rootDisplay;
		}
		public function set rootDisplay(value:DisplayLayer):void{
			_rootDisplay = value;
		}
		
		private var _rootDisplay:DisplayLayer;
		private var _scaleBelowMin:Boolean;
		private var _minAppSize:Rectangle;
		private var _initialAdvice:Array;
		private var _advisors:Array;
		
	}
}