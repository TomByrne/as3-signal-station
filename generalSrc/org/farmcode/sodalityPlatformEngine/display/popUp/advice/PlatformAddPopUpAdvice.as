package org.farmcode.sodalityPlatformEngine.display.popUp.advice
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.utils.Dictionary;
	
	import org.farmcode.sodalityLibrary.display.popUp.advice.AdvancedAddPopUpAdvice;
	import org.farmcode.sodalityPlatformEngine.display.DisplayLayer;
	import org.farmcode.sodalityPlatformEngine.display.popUp.adviceTypes.IPlatformAddPopUpAdvice;

	public class PlatformAddPopUpAdvice extends AdvancedAddPopUpAdvice implements IPlatformAddPopUpAdvice
	{
		[Property(toString="true",clonable="true")]
		public function get displayLayer():DisplayLayer{
			return this._displayLayer;
		}
		public function set displayLayer(value: DisplayLayer): void{
			this._displayLayer = value;
		}
		
		/*public function get displayLayerPath():String{
			return this._displayLayerPath;
		}*/
		public function set displayLayerPath(value: String): void{
			this._displayLayerPath = value;
		}
		[Property(toString="true",clonable="true")]
		public function get focusAdvice():Array{
			return _focusAdvice;
		}
		public function set focusAdvice(value:Array):void{
			//if(_focusAdvice != value){
				_focusAdvice = value;
			//}
		}	
		
		[Property(toString="true",clonable="true")]
		override public function get popUpParent():DisplayObjectContainer{
			return (super.popUpParent?super.popUpParent:(_displayLayer?_displayLayer.display:null));
		}
		[Property(toString="true",clonable="true")]
		override public function get resolvePaths() : Array{
			var ret:Array = super.resolvePaths;
			if(!_displayLayer && _displayLayerPath)ret.push(_displayLayerPath);
			return ret;
		}
		override public function set resolvedObjects(value:Dictionary) : void{
			super.resolvedObjects = value;
			var displayLayer:DisplayLayer = value[displayLayer];
			if(displayLayer)this.displayLayer = displayLayer;
		}
		
		private var _displayLayer:DisplayLayer;
		private var _displayLayerPath:String;
		private var _focusAdvice:Array;
		
		public function PlatformAddPopUpAdvice(displayPath:String=null, display:DisplayObject=null){
			super(displayPath, display);
		}
	}
}