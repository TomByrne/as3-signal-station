package org.farmcode.display.utils
{
	import org.farmcode.acting.actTypes.IAct;
	import org.farmcode.acting.acts.Act;
	import org.farmcode.display.assets.assetTypes.IDisplayAsset;

	/**
	 * PaddingSizer sizes/positions a IDisplayAsset based on two sets of paddings.
	 * The first set is the assumed paddings, these come from the skin/asset generally.
	 * The second set overrides the first and is specified by the user/config/developer.
	 * PaddingSizer doesn't do any processing till it's draw method is called. 
	 */
	public class PaddingSizer
	{
		
		/**
		 * handler(from:PaddingSizer)
		 */
		public function get paddingChanged():IAct{
			if(!_paddingChanged)_paddingChanged = new Act();
			return _paddingChanged;
		}
		
		
		
		public function get assumedPaddingTop():Number{
			return _assumedPaddingTop;
		}
		public function set assumedPaddingTop(value:Number):void{
			if(_assumedPaddingTop!=value){
				_assumedPaddingTop = value;
				if(isNaN(_explicitPaddingTop)){
					var newVal:Number = (isNaN(value)?0:value);
					if(_paddingTop != newVal){
						_paddingTop = newVal;
						if(_paddingChanged)_paddingChanged.perform(this);
					}
				}
			}
		}
		public function get assumedPaddingLeft():Number{
			return _assumedPaddingLeft;
		}
		public function set assumedPaddingLeft(value:Number):void{
			if(_assumedPaddingLeft!=value){
				_assumedPaddingLeft = value;
				if(isNaN(_explicitPaddingLeft)){
					var newVal:Number = (isNaN(value)?0:value);
					if(_paddingLeft != newVal){
						_paddingLeft = newVal;
						if(_paddingChanged)_paddingChanged.perform(this);
					}
				}
			}
		}
		public function get assumedPaddingBottom():Number{
			return _assumedPaddingBottom;
		}
		public function set assumedPaddingBottom(value:Number):void{
			if(_assumedPaddingBottom!=value){
				_assumedPaddingBottom = value;
				if(isNaN(_explicitPaddingBottom)){
					var newVal:Number = (isNaN(value)?0:value);
					if(_paddingBottom != newVal){
						_paddingBottom = newVal;
						if(_paddingChanged)_paddingChanged.perform(this);
					}
				}
			}
		}
		public function get assumedPaddingRight():Number{
			return _assumedPaddingRight;
		}
		public function set assumedPaddingRight(value:Number):void{
			if(_assumedPaddingRight!=value){
				_assumedPaddingRight = value;
				if(!isNaN(_explicitPaddingRight)){
					_paddingRight = (isNaN(value)?0:value);
				}
				if(isNaN(_explicitPaddingRight)){
					var newVal:Number = (isNaN(value)?0:value);
					if(_paddingRight != newVal){
						_paddingRight = newVal;
						if(_paddingChanged)_paddingChanged.perform(this);
					}
				}
			}
		}
		
		
		
		public function get explicitPaddingTop():Number{
			return _explicitPaddingTop;
		}
		public function set explicitPaddingTop(value:Number):void{
			if(_explicitPaddingTop!=value){
				_explicitPaddingTop = value;
				if(!isNaN(value) && _paddingTop != value){
					_paddingTop = value;
					if(_paddingChanged)_paddingChanged.perform(this);
				}
			}
		}
		public function get explicitPaddingLeft():Number{
			return _explicitPaddingLeft;
		}
		public function set explicitPaddingLeft(value:Number):void{
			if(_explicitPaddingLeft!=value){
				_explicitPaddingLeft = value;
				if(!isNaN(value) && _paddingLeft != value){
					_paddingLeft = value;
					if(_paddingChanged)_paddingChanged.perform(this);
				}
			}
		}
		public function get explicitPaddingBottom():Number{
			return _explicitPaddingBottom;
		}
		public function set explicitPaddingBottom(value:Number):void{
			if(_explicitPaddingBottom!=value){
				_explicitPaddingBottom = value;
				if(!isNaN(value) && _paddingBottom != value){
					_paddingBottom = value;
					if(_paddingChanged)_paddingChanged.perform(this);
				}
			}
		}
		public function get explicitPaddingRight():Number{
			return _explicitPaddingRight;
		}
		public function set explicitPaddingRight(value:Number):void{
			if(_explicitPaddingRight!=value){
				_explicitPaddingRight = value;
				if(!isNaN(value) && _paddingRight != value){
					_paddingRight = value;
					if(_paddingChanged)_paddingChanged.perform(this);
				}
			}
		}
		
		
		public function get paddingTop():Number{
			return _paddingTop;
		}
		public function get paddingLeft():Number{
			return _paddingLeft;
		}
		public function get paddingBottom():Number{
			return _paddingBottom;
		}
		public function get paddingRight():Number{
			return _paddingRight;
		}
		
		
		public function get targetDisplay():IDisplayAsset{
			return _targetDisplay;
		}
		public function set targetDisplay(value:IDisplayAsset):void{
			if(_targetDisplay!=value){
				_targetDisplay = value;
				_lastX = NaN;
				_lastY = NaN;
				_lastW = NaN;
				_lastH = NaN;
			}
		}
		
		protected var _paddingChanged:Act;
		private var _targetDisplay:IDisplayAsset;
		
		private var _assumedPaddingRight:Number;
		private var _assumedPaddingBottom:Number;
		private var _assumedPaddingLeft:Number;
		private var _assumedPaddingTop:Number;
		
		private var _explicitPaddingRight:Number;
		private var _explicitPaddingBottom:Number;
		private var _explicitPaddingLeft:Number;
		private var _explicitPaddingTop:Number;
		
		private var _paddingRight:Number = 0;
		private var _paddingBottom:Number = 0;
		private var _paddingLeft:Number = 0;
		private var _paddingTop:Number = 0;
		
		private var _lastX:Number;
		private var _lastY:Number;
		private var _lastW:Number;
		private var _lastH:Number;
		
		
		public function PaddingSizer(){
		}
		public function draw(x:Number, y:Number, width:Number, height:Number):void{
			var newX:Number = x+_paddingLeft;
			var newY:Number = y+_paddingTop;
			var newW:Number = width-_paddingLeft-_paddingRight;
			var newH:Number = height-_paddingTop-_paddingBottom;
			
			var difX:Boolean = (newX!=_lastX);
			var difY:Boolean = (newY!=_lastY);
			var difW:Boolean = (newW!=_lastW);
			var difH:Boolean = (newH!=_lastH);
			
			if((difX || difY) && (difW || difH)){
				_targetDisplay.setSizeAndPos(newX,newY,newW,newH);
			}else{
				if(difX && difY){
					_targetDisplay.setPosition(newX,newY);
				}else if(difX){
					_targetDisplay.x = newX;
				}else if(difY){
					_targetDisplay.y = newY;
				}
				if(difW && difH){
					_targetDisplay.setSize(newW,newH);
				}else if(difW){
					_targetDisplay.width = newW;
				}else if(difH){
					_targetDisplay.height = newH;
				}
			}
			_lastX = newX;
			_lastY = newY;
			_lastW = newW;
			_lastH = newH;
		}
	}
}