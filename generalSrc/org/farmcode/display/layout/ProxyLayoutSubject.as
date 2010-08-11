package org.farmcode.display.layout
{
	import flash.errors.InvalidSWFError;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import org.farmcode.acting.actTypes.IAct;
	import org.farmcode.acting.acts.Act;
	import org.farmcode.display.layout.core.ILayoutInfo;
	
	public class ProxyLayoutSubject implements ILayoutSubject
	{
		public function get measurements():Point{
			return _realMeasurements;
		}
		public function set measurements(value:Point):void{
			if(_forceMeasurements!=value){
				_forceMeasurements = value;
				checkMeasurements();
			}
		}
		
		public function get displayPosition():Rectangle{
			return _displayPosition;
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
				var oldMeas:Point;
				if(_target){
					_target.measurementsChanged.removeHandler(onMeasurementsChanged);
					oldMeas = _target.measurements;
				}
				_target = value;
				if(_target){
					_target.measurementsChanged.addHandler(onMeasurementsChanged);
					if(!_forceMeasurements && (!oldMeas || !_target.measurements.equals(oldMeas))){
						checkMeasurements();
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
		/**
		 * @inheritDoc
		 */
		public function get positionChanged():IAct{
			if(!_positionChanged)_positionChanged = new Act();
			return _positionChanged;
		}
		
		protected var _positionChanged:Act;
		protected var _measurementsChanged:Act;
		
		private var _target:ILayoutSubject;
		private var _layoutInfo:ILayoutInfo;
		private var _forceMeasurements:Point;
		private var _realMeasurements:Point;
		protected var _displayPosition:Rectangle;
		
		public function ProxyLayoutSubject(target:ILayoutSubject=null){
			_displayPosition = new Rectangle();
			this.target = target;
			_realMeasurements = new Point();
		}
		
		public function setDisplayPosition(x:Number, y:Number, width:Number, height:Number):void{
			if(_positionChanged){
				var oldX:Number = _displayPosition.x;
				var oldY:Number = _displayPosition.y;
				var oldWidth:Number = _displayPosition.width;
				var oldHeight:Number = _displayPosition.height;
			}
			var change:Boolean = false;
			if(_displayPosition.x!=x){
				_displayPosition.x = x;
				change = true;
			}
			if(_displayPosition.y!=y){
				_displayPosition.y = y;
				change = true;
			}
			if(_displayPosition.width!=width){
				_displayPosition.width = width;
				change = true;
			}
			if(_displayPosition.height!=height){
				_displayPosition.height = height;
				change = true;
			}
			if(change){
				if(_target)_target.setDisplayPosition(x,y,width,height);
				if(_positionChanged)_positionChanged.perform(this,oldX,oldY,oldWidth,oldHeight);
			}
		}
		protected function onMeasurementsChanged(from:ILayoutSubject, oldWidth:Number, oldHeight:Number):void{
			if(!_forceMeasurements){
				checkMeasurements();
			}
		}
		protected function checkMeasurements():void{
			var meas:Point;
			if(_forceMeasurements){
				meas = _forceMeasurements;
			}else if(_target){
				meas = target.measurements;
			}
			if(_realMeasurements.x!=meas.x || _realMeasurements.y!=meas.y){
				var oldMeasWidth:Number = _realMeasurements.x;
				var oldMeasHeight:Number = _realMeasurements.y;
				_realMeasurements.x = meas.x;
				_realMeasurements.y = meas.y;
				if(_measurementsChanged)_measurementsChanged.perform(this, oldMeasWidth, oldMeasHeight);
			}
		}
	}
}