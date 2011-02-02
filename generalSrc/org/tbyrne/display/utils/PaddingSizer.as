package org.tbyrne.display.utils
{
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.acting.acts.Act;
	import org.tbyrne.display.assets.nativeTypes.IDisplayObject;

	/**
	 * PaddingSizer sizes/positions a IDisplayObject based on two sets of paddings.
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
				
				var newValue:Number;
				if(!isNaN(value)){
					newValue = value;
				}else if(!isNaN(_assumedPaddingTop)){
					newValue = _assumedPaddingTop;
				}else{
					newValue = 0;
				}
				if(_paddingTop != newValue){
					_paddingTop = newValue;
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
				
				var newValue:Number;
				if(!isNaN(value)){
					newValue = value;
				}else if(!isNaN(_assumedPaddingLeft)){
					newValue = _assumedPaddingLeft;
				}else{
					newValue = 0;
				}
				if(_paddingLeft != newValue){
					_paddingLeft = newValue;
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
				
				var newValue:Number;
				if(!isNaN(value)){
					newValue = value;
				}else if(!isNaN(_assumedPaddingBottom)){
					newValue = _assumedPaddingBottom;
				}else{
					newValue = 0;
				}
				if(_paddingBottom != newValue){
					_paddingBottom = newValue;
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
				
				var newValue:Number;
				if(!isNaN(value)){
					newValue = value;
				}else if(!isNaN(_assumedPaddingRight)){
					newValue = _assumedPaddingRight;
				}else{
					newValue = 0;
				}
				if(_paddingRight != newValue){
					_paddingRight = newValue;
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
		
		
		public function get targetDisplay():IDisplayObject{
			return _targetDisplay;
		}
		public function set targetDisplay(value:IDisplayObject):void{
			if(_targetDisplay!=value){
				_targetDisplay = value;
				_lastX = NaN;
				_lastY = NaN;
				_lastW = NaN;
				_lastH = NaN;
			}
		}
		
		protected var _paddingChanged:Act;
		private var _targetDisplay:IDisplayObject;
		
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