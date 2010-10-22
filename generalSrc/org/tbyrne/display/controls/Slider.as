package org.tbyrne.display.controls
{
	
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.acting.acts.Act;
	import org.tbyrne.core.DelayedCall;
	import org.tbyrne.display.DisplayNamespace;
	import org.tbyrne.display.assets.assetTypes.IDisplayAsset;
	import org.tbyrne.display.assets.assetTypes.IInteractiveObjectAsset;
	import org.tbyrne.display.constants.Direction;
	import org.tbyrne.display.utils.PaddingSizer;
	
	use namespace DisplayNamespace;
	
	//TODO: make this use proper data types (i.e. INumberProvider/INumberConsumer)
	public class Slider extends Control
	{
		DisplayNamespace static const TRACK:String = "track";
		DisplayNamespace static const PROGRESS_TRACK:String = "progressTrack";
		DisplayNamespace static const THUMB:String = "thumb";
		
		
		public function get direction():String{
			return _direction?_direction:_assumedDirection;
		}
		public function set direction(value:String):void{
			if(_direction!=value){
				_direction = value;
				invalidateSize();
			}
		}
		
		public function get maximum():Number{
			return _maximum;
		}
		public function set maximum(value:Number):void{
			if(_maximum!=value){
				_maximum = value;
				invalidateSize();
			}
		}
		
		public function get minimum():Number{
			return _minimum;
		}
		public function set minimum(value:Number):void{
			if(_minimum!=value){
				_minimum = value;
				invalidateSize();
			}
		}
		
		public function get updateDuringDrag():Boolean{
			return _updateDuringDrag;
		}
		public function set updateDuringDrag(value:Boolean):void{
			if(_updateDuringDrag!=value){
				_updateDuringDrag = value;
			}
		}
		
		public function get value():Number{
			if(_value<_minimum){
				return minimum;
			}else if(_value>maximum){
				return maximum;
			}else{
				return _value;
			}
		}
		public function set value(value:Number):void{
			if(_value!=value && !_dragDelay.running){
				_value = value;
				if(_valueChange)_valueChange.perform(this,this.value);
				invalidateSize();
			}
		}
		override public function set active(value:Boolean):void{
			super.active = value;
			_trackButton.active = value;
			_thumb.active = value;
			_progressTrack.active = value;
		}
		
		
		/**
		 * handler(from:Slider, value:Number)
		 */
		public function get valueChanged():IAct{
			if(!_valueChange)_valueChange = new Act();
			return _valueChange;
		}
		/**
		 * handler(from:Slider, value:Number)
		 */
		public function get valueChangedByUser():IAct{
			if(!_valueChangeByUser)_valueChangeByUser = new Act();
			return _valueChangeByUser;
		}
		
		private var _valueChangeByUser:Act;
		private var _valueChange:Act;
		
		private var _value:Number = 0;
		private var _minimum:Number = 0;
		private var _maximum:Number = 1;
		private var _direction:String;
		private var _updateDuringDrag:Boolean = false;
		
		private var _trackButton:Button;
		private var _progressTrack:Button;
		private var _thumb:Button;
		private var _track:IDisplayAsset;
		private var _ignoreThumb:Boolean;
		
		private var _assumedDirection:String;
		private var _assumedThumbX:Number;
		private var _assumedThumbY:Number;
		
		private var _trackPadding:PaddingSizer;
		
		private var _dragOffset:Number;
		private var _dragStartValue:Number;
		private var _dragDelay:DelayedCall = new DelayedCall(doDrag,1,false,null,0);
		
		public function Slider(){
			super();
		}
		override protected function init():void{
			super.init();
			_trackPadding = new PaddingSizer();
			
			_trackButton = new Button();
			_trackButton.scaleAsset = true;
			_trackButton.clicked.addHandler(onTrackClick);
			
			_progressTrack = new Button();
			_progressTrack.scaleAsset = true;
			_progressTrack.clicked.addHandler(onTrackClick);
			
			_thumb = new Button();
			_thumb.mousePressed.addHandler(onThumbMouseDown);
			_thumb.mouseReleased.addHandler(onThumbMouseUp);
		}
		override protected function bindToAsset() : void{
			super.bindToAsset();
			
			_track = _containerAsset.takeAssetByName(TRACK,IInteractiveObjectAsset);
			_trackButton.asset = _track;
			
			_progressTrack.asset = _containerAsset.takeAssetByName(PROGRESS_TRACK,IInteractiveObjectAsset,false);
			
			_assumedDirection = (_track.width>_track.height?Direction.HORIZONTAL:Direction.VERTICAL);
			
			_thumb.asset = _containerAsset.takeAssetByName(THUMB,IInteractiveObjectAsset);
			
			_assumedThumbX = _thumb.asset.x;
			_assumedThumbY = _thumb.asset.y;
			
			if(_backing){
				_trackPadding.assumedPaddingTop = _track.y;
				_trackPadding.assumedPaddingBottom = _backing.naturalHeight-(_track.y+_track.naturalHeight);
				_trackPadding.assumedPaddingLeft = _track.x;
				_trackPadding.assumedPaddingRight = _backing.naturalWidth-(_track.x+_track.naturalWidth);
			}else{
				_trackPadding.assumedPaddingTop = 0;
				_trackPadding.assumedPaddingBottom = 0;
				_trackPadding.assumedPaddingLeft = 0;
				_trackPadding.assumedPaddingRight = 0;
			}
		}
		override protected function unbindFromAsset() : void{
			super.unbindFromAsset();
			if(_progressTrack.asset){
				_containerAsset.returnAsset(_progressTrack.asset);
				_progressTrack.asset = null;
			}
			_containerAsset.returnAsset(_trackButton.asset);
			_trackButton.asset = null;
			_track = null;
			
			_containerAsset.returnAsset(_thumb.asset);
			_thumb.asset = null;
		}
		override protected function measure():void{
			super.measure();
		}
		override protected function commitSize():void{
			var dir:String = direction;
			
			_asset.scaleX = 1;
			_asset.scaleY = 1;
			
			var fract:Number = (value-_minimum)/(_maximum-_minimum);
			
			var usableW:Number;
			var usableH:Number;
			
			var pad:PaddingSizer = _trackPadding;
			
			if(dir==_assumedDirection){
				_track.rotation = _thumb.asset.rotation = (dir!=_assumedDirection?90:0);
				usableW = _size.x-pad.paddingLeft-pad.paddingRight;
				usableH = _size.y-pad.paddingTop-pad.paddingBottom;
			}else{
				usableW = _size.x-pad.paddingTop-pad.paddingBottom;
				usableH = _size.y-pad.paddingLeft-pad.paddingRight;
			}
			
			
			var thumbX:Number;
			var thumbY:Number;
			var trackX:Number;
			var trackY:Number;
			var trackWidth:Number;
			var trackHeight:Number;
			
			var pTrackY:Number;
			var pTrackWidth:Number;
			var pTrackHeight:Number;
			
			if(dir==Direction.VERTICAL){
				var natWidth:Number = _track.naturalWidth;
				if(natWidth<usableW){
					trackWidth = natWidth;
					trackX = (usableW-_track.width)/2;
				}else{
					trackWidth = usableW;
					trackX = pad.paddingLeft;
				}
				trackHeight = usableH;
				trackY = pad.paddingTop;
				thumbX = _assumedThumbX;
				thumbY = _track.y+(_track.height-_thumb.asset.height)*(1-fract);
				
				pTrackY = thumbY+_thumb.asset.height/2;
				pTrackWidth = trackWidth;
				pTrackHeight = trackY+trackHeight-pTrackY;
			}else{
				var natHeight:Number = _track.naturalHeight;
				if(natHeight<usableH){
					trackHeight = natHeight;
					trackY = (usableH-_track.height)/2;
				}else{
					trackHeight = usableH;
					trackY = pad.paddingTop;
				}
				trackWidth = usableW;
				trackX = pad.paddingLeft;
				thumbY = _assumedThumbY;
				thumbX = trackX+(trackWidth-_thumb.asset.width)*fract;
				
				pTrackY = trackY;
				pTrackWidth = thumbX+_thumb.asset.width/2;
				pTrackHeight = trackHeight;
			}
			_thumb.setPosition(thumbX,thumbY);
			_thumb.setSize(_thumb.asset.width,_thumb.asset.height);
			
			_trackButton.setPosition(trackX,trackY);
			_trackButton.setSize(trackWidth,trackHeight);
			
			_progressTrack.setPosition(trackX,pTrackY);
			_progressTrack.setSize(pTrackWidth,pTrackHeight);
			
			_progressTrack.validate();
		}
		override public function setAssetAndPosition(asset:IDisplayAsset) : void{
			super.setAssetAndPosition(asset);
			checkIsBound();
		}
		protected function onTrackClick(from:Button):void{
			if(_active){
				_dragOffset = 0;
				setValueToMouse();
			}
		}
		protected function onThumbMouseDown(from:Button):void{
			if(_active && !_ignoreThumb){
				if(direction==Direction.VERTICAL){
					_dragOffset = _thumb.asset.mouseY-_thumb.asset.height/2;
				}else{
					_dragOffset = _thumb.asset.mouseX-_thumb.asset.width/2;
				}
				_dragStartValue = _value;
				_dragDelay.begin();
			}
		}
		protected function doDrag():void{
			setValueToMouse();
		}
		protected function onThumbMouseUp(from:Button):void{
			if(_ignoreThumb || !_dragDelay.running)return;
			_dragDelay.clear();
			setValueToMouse();
			_dragOffset = 0;
			if(!_updateDuringDrag && _dragStartValue!=_value){
				if(_valueChange)_valueChange.perform(this,_value);
				if(_valueChangeByUser)_valueChangeByUser.perform(this,_value);
			}
		}
		protected function setValueToMouse():void{
			var newVal:Number;
			if(direction==Direction.VERTICAL){
				newVal = 1-((asset.mouseY-_dragOffset-_thumb.asset.height/2)/(_track.height-_thumb.asset.height));
			}else{
				newVal = (asset.mouseX-_dragOffset-_thumb.asset.width/2)/(_track.width-_thumb.asset.width);
			}
			if(newVal<0)newVal = minimum;
			else if(newVal>1)newVal = maximum;
			else newVal = (newVal*(maximum-minimum))+minimum;
			
			if(_value!=newVal){
				_value = newVal;
				_ignoreThumb = true;
				validate(true);
				_ignoreThumb = false;
				if(_updateDuringDrag || !_dragDelay.running){
					if(_valueChange)_valueChange.perform(this,_value);
					if(_valueChangeByUser)_valueChangeByUser.perform(this,_value);
				}
			}
		}
	}
}