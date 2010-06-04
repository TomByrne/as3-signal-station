package org.farmcode.display.layout
{
	import flash.geom.Rectangle;
	
	import org.farmcode.acting.actTypes.IAct;
	import org.farmcode.acting.acts.Act;
	import org.farmcode.display.layout.core.ILayoutInfo;
	
	public class ProxyLayoutSubject implements ILayoutSubject
	{
		public function get displayMeasurements():Rectangle{
			var ret:Rectangle;
			if(_displayMeasurements){
				ret = _displayMeasurements;
			}else if(_target){
				ret = target.displayMeasurements;
			}
			if(ret){
				_oldMeasX = ret.x;
				_oldMeasY = ret.y;
				_oldMeasWidth = ret.width;
				_oldMeasHeight = ret.height;
			}else{
				_oldMeasX = NaN;
				_oldMeasY = NaN;
				_oldMeasWidth = NaN;
				_oldMeasHeight = NaN;
			}
			return ret;
		}
		public function set displayMeasurements(value:Rectangle):void{
			if(_displayMeasurements!=value){
				_displayMeasurements = value;
				dispatchMeasurementsChanged();
			}
		}
		
		public function get layoutInfo():ILayoutInfo{
			if(_layoutInfo){
				return _layoutInfo;
			}else if(_target){
				return target.layoutInfo;
			}else{
				return null;
			}
		}
		public function set layoutInfo(value:ILayoutInfo):void{
			_layoutInfo = value;
		}
		
		public function get target():ILayoutSubject{
			return _target;
		}
		public function set target(value:ILayoutSubject):void{
			if(_target!=value){
				if(_target){
					_target.measurementsChanged.removeHandler(onMeasurementsChanged);
				}
				_target = value;
				if(_target){
					_target.measurementsChanged.addHandler(onMeasurementsChanged);
					if(!_displayMeasurements){
						dispatchMeasurementsChanged();
					}else{
						_target.setDisplayPosition(_displayPosition.x,_displayPosition.y,_displayPosition.width,_displayPosition.height);
					}
				}
			}
		}
		

		/**
		 * @inheritDoc
		 */
		public function get measurementsChanged():IAct{
			if(!_measurementsChanged)_measurementsChanged = new Act();
			return _measurementsChanged;
		}
		
		protected var _measurementsChanged:Act;
		protected var _oldMeasX:Number;
		protected var _oldMeasY:Number;
		protected var _oldMeasWidth:Number;
		protected var _oldMeasHeight:Number;
		
		private var _target:ILayoutSubject;
		private var _layoutInfo:ILayoutInfo;
		private var _displayMeasurements:Rectangle;
		protected var _displayPosition:Rectangle;
		
		public function ProxyLayoutSubject(target:ILayoutSubject=null){
			_displayPosition = new Rectangle();
			this.target = target;
		}
		
		public function setDisplayPosition(x:Number, y:Number, width:Number, height:Number):void{
			_displayPosition.x = x;
			_displayPosition.y = y;
			_displayPosition.width = width;
			_displayPosition.height = height;
			if(_target){
				_target.setDisplayPosition(x,y,width,height);
			}
		}
		protected function onMeasurementsChanged(from:ILayoutSubject, oldX:Number, oldY:Number, oldWidth:Number, oldHeight:Number):void{
			if(!_displayMeasurements){
				dispatchMeasurementsChanged();
			}
		}
		protected function dispatchMeasurementsChanged():void{
			if(_measurementsChanged)_measurementsChanged.perform(this,_oldMeasX, _oldMeasY, _oldMeasWidth, _oldMeasHeight);
		}
		/*protected function dispatchEventIf(eventType:String, eventClass:Class):void{
			if(willTrigger(eventType)){
				dispatchEvent(new eventClass(eventType));
			}
		}*/
	}
}