package au.com.thefarmdigital.tweening
{
	import flash.display.DisplayObject;
	import flash.geom.Matrix;
	import flash.utils.Dictionary;
	
	public class MatrixTween extends AbstractTween
	{
		private static const MATRIX_PROPS:Array = ["a","b","c","d","tx","ty"];
		
		public function get target():DisplayObject{
			return _target;
		}
		public function set target(value:DisplayObject):void{
			_target = value;
		}
		
		
		public function get startMatrix():Matrix{
			return _startMatrix;
		}
		public function set startMatrix(value:Matrix):void{
			_startMatrix = value;
		}
		
		
		public function get destMatrix():Matrix{
			return _destMatrix;
		}
		public function set destMatrix(value:Matrix):void{
			_destMatrix = value;
		}
		
		private var _applyMatrix:Matrix = new Matrix();
		private var _destMatrix:Matrix;
		private var _startMatrix:Matrix;
		private var _target:DisplayObject;
		
		private var _realStart:Dictionary;
		private var _realChange:Dictionary;
		
		public function MatrixTween(target:DisplayObject=null, destMatrix:Matrix=null, easing:Function=null, duration:Number=NaN, useFrames:Boolean=false){
			if(target)this.target = target;
			if(destMatrix)this.destMatrix = destMatrix;
			if(easing!=null)this.easing = easing;
			if(!isNaN(duration))this.duration = duration;
			this.useFrames = useFrames;
		}
		
		override public function start() : Boolean {
			super.start();
			_realStart = new Dictionary();
			_realChange = new Dictionary();
			var startMarix:Matrix = (_startMatrix?_startMatrix:target.transform.matrix);
			for each(var prop:String in MATRIX_PROPS){
				var dest:Number = _destMatrix[prop];
				var start:Number = startMarix[prop];
				_realStart[prop] = start;
				
				if(useRelative){
					_realChange[prop] = dest;
				}else{
					_realChange[prop] = dest-start;
				}
			}
			return true;
		}
		override protected function onUpdate(type : String) : void{
			super.onUpdate(type);
			for each(var prop:String in MATRIX_PROPS){
				var value:Number = _realStart[prop]+(_realChange[prop]*position);
				if(useRounding)value = Math.round(value);
				_applyMatrix[prop] = value;
			}
			target.transform.matrix = _applyMatrix;
		}
	}
}