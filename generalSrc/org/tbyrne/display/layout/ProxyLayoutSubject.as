package org.tbyrne.display.layout
{
	import flash.errors.InvalidSWFError;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.acting.acts.Act;
	import org.tbyrne.display.core.ILayoutView;
	import org.tbyrne.display.layout.core.ILayoutInfo;
	
	public class ProxyLayoutSubject extends LayoutSubject
	{
		
		override public function get layoutInfo():ILayoutInfo{
			if(_layoutInfo){
				return _layoutInfo;
			}else if(_target){
				return target.layoutInfo;
			}else{
				return null;
			}
		}
		public function set measurements(value:Point):void{
			if((!_forceMeasurements && value) || 
				(!_forceMeasurements.equals(value))){
				_forceMeasurements = value;
				invalidateMeasurements();
			}
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
				setScopeView(value as ILayoutView);
				if(_target){
					_target.setPosition(_position.x,_position.y);
					_target.setSize(_size.x,_size.y);
					_target.measurementsChanged.addHandler(onMeasurementsChanged);
					if(!_forceMeasurements){
						invalidateMeasurements();
					}
				}
			}

		}
		
		private var _target:ILayoutSubject;
		private var _forceMeasurements:Point;
		
		public function ProxyLayoutSubject(target:ILayoutSubject=null){
			this.target = target;
		}
		override protected function measure():void{
			if(_forceMeasurements){
				_measurements.x = _forceMeasurements.x;
				_measurements.y = _forceMeasurements.y;
			}else{
				var meas:Point = _target.measurements;
				if(meas){
					_measurements.x = meas.x;
					_measurements.y = meas.y;
				}else{
					_measurements.x = NaN;
					_measurements.y = NaN;
				}
			}
		}
		override protected function validatePosition():void{
			_target.setPosition(_position.x,_position.y);
		}
		override protected function validateSize():void{
			_target.setSize(_size.x,_size.y);
		}
		protected function onMeasurementsChanged(from:ILayoutSubject, oldWidth:Number, oldHeight:Number):void{
			if(!_forceMeasurements){
				invalidateMeasurements();
			}
		}
	}
}