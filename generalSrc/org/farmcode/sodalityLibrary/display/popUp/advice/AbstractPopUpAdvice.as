package org.farmcode.sodalityLibrary.display.popUp.advice
{
	import flash.display.DisplayObject;
	import flash.utils.Dictionary;
	
	import org.farmcode.hoborg.Cloner;
	import org.farmcode.sodalityLibrary.display.transition.advice.TransitionAdvice;
	import org.farmcode.sodalityLibrary.external.siteStream.adviceTypes.IResolvePathsAdvice;

	public class AbstractPopUpAdvice extends TransitionAdvice implements IResolvePathsAdvice
	{
		
		public function AbstractPopUpAdvice(displayPath:String=null, display:DisplayObject=null){
			this.displayPath = displayPath;
			this.display = display;
		}
		
		private var _display:DisplayObject;
		protected var _displayPath:String;
		
		[Property(toString="true",clonable="true")]
		public function get display():DisplayObject{
			return _display;
		}
		public function set display(value:DisplayObject):void{
			_display = value;
		}
		[Property(toString="true",clonable="true")]
		public function get displayPath():String{
			return _displayPath;
		}
		public function set displayPath(value:String):void{
			_displayPath = value;
		}
		
		public function get resolvePaths():Array{
			return display?[]:[_displayPath];
		}
		public function set resolvedObjects(value:Dictionary):void{
			Cloner.setPropertyInClones(this,"resolvedObjects",value);
			if(_displayPath){
				var resolved:* = value[_displayPath];
				if(resolved){
					var cast:DisplayObject = (resolved as DisplayObject);
					if(cast){
						display = cast;
					}else{
						cast = (resolved.display as DisplayObject);
						if(cast)display = cast;
					}
				}
			}
		}
	}
}