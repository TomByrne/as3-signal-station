package org.tbyrne.display.controls.toolTip
{
	import flash.geom.Point;
	
	import org.tbyrne.display.assets.nativeTypes.ITextField;
	import org.tbyrne.display.core.DrawableView;
	import org.tbyrne.display.validation.FrameValidationFlag;

	public class ToolTipAnnotator extends DrawableView implements IToolTipManager
	{
		public static const SYMBOLIC_TYPE:String = "symbolic";
		public static const NUMERIC_TYPE:String = "numeric";
		
		public static const DEFAULT_PATTERN:String = "${k} ${d}   ";
		
		private static const SYMBOLS:Array = ["*", "†", "‡", "§", "‖", "¶"];
		
		public function get annotationType():String{
			return _annotationType;
		}
		public function set annotationType(value:String):void{
			if(_annotationType!=value){
				_annotationType = value;
				_tipsFlag.invalidate();
			}
		}
		
		public function get annotationPattern():String{
			return _annotationPattern;
		}
		public function set annotationPattern(value:String):void{
			if(_annotationPattern!=value){
				_annotationPattern = value;
				_tipsFlag.invalidate();
			}
		}
		
		private var _annotationPattern:String = DEFAULT_PATTERN;
		private var _annotationType:String = NUMERIC_TYPE;
		private var _tipTriggers:Array = [];
		private var _textField:ITextField;
		
		private var _tipsFlag:FrameValidationFlag;
		
		public function ToolTipAnnotator(){
			_tipsFlag = new FrameValidationFlag(this,commitTips,false);
		}
		public function addTipTrigger(trigger:IToolTipTrigger):void{
			_tipTriggers.push(trigger);
			_tipsFlag.invalidate();
		}
		public function removeTipTrigger(trigger:IToolTipTrigger):void{
			var index:int = _tipTriggers.indexOf(trigger);
			_tipTriggers.splice(index,1);
			_tipsFlag.invalidate();
		}
		override protected function bindToAsset() : void{
			super.bindToAsset();
			_textField = _asset as ITextField;
		}
		override protected function unbindFromAsset() : void{
			super.unbindFromAsset();
			_textField = null;
		}
		protected function commitTips():void{
			_tipTriggers = _tipTriggers.sort(sortTips);
			var text:String = "";
			var count:int = 0;
			for(var i:int=0; i<_tipTriggers.length; i++){
				var trigger:IToolTipTrigger = _tipTriggers[i];
				var data:String = trigger.data as String;
				if(data){
					var key:String = getAnnotationKey(count,_annotationType);
					trigger.annotationKey = key;
					++count;
					var annot:String = _annotationPattern;
					annot = annot.replace("${k}",key);
					annot = annot.replace("${d}",data);
					text += annot;
				}
			}
			_textField.text = text;
		}
		protected function sortTips(trigger1:IToolTipTrigger, trigger2:IToolTipTrigger) : int{
			if(trigger1.anchorView && trigger1.anchorView.asset && trigger2.anchorView && trigger2.anchorView.asset && trigger1.data && trigger2.data){
				var point1:Point = trigger1.anchorView.asset.localToGlobal(new Point());
				var point2:Point = trigger2.anchorView.asset.localToGlobal(new Point());
				if(point1.y<point2.y || (point1.y==point2.y && point1.x<point2.x)){
					return -1;
				}else{
					return 1;
				}
			}else{
				return 0;
			}
		}
		protected function getAnnotationKey(index:int, type:String) : String{
			if(type==SYMBOLIC_TYPE){
				var count:Number = index/SYMBOLS.length;
				
				if(count%1)count = int(count+1);
					else count = int(count);
				
				var key:String = SYMBOLS[index%SYMBOLS.length];
				var ret:String = "";
				for(var i:int=0; i<count; i++){
					ret += key;
				}
				return ret;
			}else if(type==NUMERIC_TYPE){
				return (index+1)+".";
			}else{
				return null;
			}
		}
	}
}