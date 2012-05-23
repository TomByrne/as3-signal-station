package org.tbyrne.display.layout
{
	import flash.geom.Point;
	
	import org.tbyrne.display.core.ILayoutView;
	import org.tbyrne.display.layout.core.ILayoutInfo;
	import org.tbyrne.hoborg.IPoolable;
	import org.tbyrne.hoborg.ObjectPool;
	
	public class ProxyLayoutSubject extends LayoutSubject implements IPoolable
	{
		private static const pool:ObjectPool = new ObjectPool(ProxyLayoutSubject);
		public static function getNew(target:ILayoutSubject=null):ProxyLayoutSubject{
			var ret:ProxyLayoutSubject = pool.takeObject();
			ret.target = target;
			return ret;
		}
		
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
				if(value){
					// create different instance so that external code can reuse it's instance
					if(!_forceMeasurements)_forceMeasurements = new Point();
					_forceMeasurements.x = value.x;
					_forceMeasurements.y = value.y;
				}else{
					_forceMeasurements = null;
				}
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
					if(_scopeView==_target){
						setScopeView(null);
					}
				}
				_target = value;
				if(!_scopeView)setScopeView(value as ILayoutView);
				if(_target){
					if(!isNaN(_position.x) && !isNaN(_position.y))_target.setPosition(_position.x,_position.y);
					if(!isNaN(_size.x) && !isNaN(_size.y))_target.setSize(_size.x,_size.y);
					_target.measurementsChanged.addHandler(onMeasurementsChanged);
				}
				if(!_forceMeasurements){
					invalidateMeasurements();
				}
			}

		}
		
		protected var _target:ILayoutSubject;
		protected var _forceMeasurements:Point;
		
		public function ProxyLayoutSubject(target:ILayoutSubject=null){
			this.target = target;
		}
		override protected function measure():void{
			if(_forceMeasurements){
				_measurements.x = _forceMeasurements.x;
				_measurements.y = _forceMeasurements.y;
			}else{
				var meas:Point = _target?_target.measurements:null;
				if(meas){
					_measurements.x = meas.x;
					_measurements.y = meas.y;
				}else{
					_measurements.x = NaN;
					_measurements.y = NaN;
				}
			}
		}
		override protected function commitPos():void{
			_target.setPosition(_position.x,_position.y);
		}
		override protected function commitSize():void{
			_target.setSize(_size.x,_size.y);
		}
		protected function onMeasurementsChanged(from:ILayoutSubject, oldWidth:Number, oldHeight:Number):void{
			if(!_forceMeasurements){
				invalidateMeasurements();
			}
		}
		public function reset():void{
			target = null;
			measurements = null;
			layoutInfo = null;
		}
		public function release():void{
			pool.releaseObject(this);
		}
	}
}