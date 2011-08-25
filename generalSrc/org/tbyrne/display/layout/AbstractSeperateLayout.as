package org.tbyrne.display.layout
{
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	import org.tbyrne.display.core.IView;
	import org.tbyrne.display.validation.ViewValidationFlag;
	import org.tbyrne.display.validation.ValidationFlag;

	/**
	 * This is the base class for layouts that affect their subjects independently
	 * as opposed to all together.
	 */
	public class AbstractSeperateLayout extends AbstractLayout
	{
		protected var _subjectFlags:Dictionary;
		protected var _subjectMeas:Dictionary;
		protected var _invalidMeas:Dictionary;
		
		public function AbstractSeperateLayout(scopeView:IView){
			super(scopeView);
			_subjectFlags = new Dictionary();
			_subjectMeas = new Dictionary();
			_invalidMeas = new Dictionary();
		}
		/** Should this layout remeasure as soon as a child subject's
		 * measurements change (to check whether the total measurements
		 * actually change) or should it wait until measurements are requested.
		 */
		protected function measureImmediately(): Boolean{
			return false;
		}
		/**
		 * @inheritDoc
		 */
		override public function addSubject(subject:ILayoutSubject):Boolean{
			if(super.addSubject(subject)){
				var subjMeas:Point = new Point();
				var params:Array =(drawToMeasure()?[subject,subjMeas]:[subject]);
				_subjectFlags[subject] = new ViewValidationFlag(scopeView, layoutSubject, false, params);
				_subjectMeas[subject] = subjMeas;
				_invalidMeas[subject] = true;
				return true;
			}
			return false;
		}
		/**
		 * @inheritDoc
		 */
		override public function removeSubject(subject:ILayoutSubject):Boolean{
			if(super.removeSubject(subject)){
				var valFlag:ViewValidationFlag = _subjectFlags[subject];
				valFlag.release();
				delete _subjectFlags[subject];
				delete _subjectMeas[subject];
				return true;
			}
			return false;
		}
		override protected function commitPos():void{
			invalidateSize();
		}
		override protected function commitSize():void{
			for each(var valFlag:ViewValidationFlag in _subjectFlags){
				valFlag.validate(true);
			}
			if(drawToMeasure()){
				compileMeasurements();
			}
		}
		/**
		 * This method should be called when the layout's measurement of a subject has changed
		 * NOT only when a subject's measurements have changed.
		 */
		protected function subjMeasurementsChanged(subject:ILayoutSubject) : void{
			if(measureImmediately()){
				var subjMeas:Point = _subjectMeas[subject];
				var oldMeasWidth:Number = subjMeas.x;
				var oldMeasHeight:Number = subjMeas.y;
				measureSubject(subject,subjMeas);
				if(oldMeasWidth!=subjMeas.x || oldMeasHeight!=subjMeas.y){
					subjMeas.x = oldMeasWidth;
					subjMeas.y = oldMeasHeight;
					compileMeasurements();
				}
			}else{
				if(drawToMeasure()){
					var valFlag:ViewValidationFlag = _subjectFlags[subject];
					valFlag.invalidate();
				}
				_invalidMeas[subject] = true;
				invalidateMeasurements();
			}
		}
		override protected function measure() : void{
			if(drawToMeasure()){
				validate(true);
				compileMeasurements();
			}else{
				for(var i:* in _invalidMeas){
					var subject:ILayoutSubject = (i as ILayoutSubject);
					var subjMeas:Point = _subjectMeas[subject];
					measureSubject(subject,subjMeas);
				}
				compileMeasurements();
			}
		}
		protected function compileMeasurements():void{
			var meas:Point = _measurements;
			var oldMeasWidth:Number = meas.x;
			var oldMeasHeight:Number = meas.y;
			meas.x = 0;
			meas.y = 0;
			for each(var subjMeas:Point in _subjectMeas){
				if(meas.x<subjMeas.x)meas.x = subjMeas.x;
				if(meas.y<subjMeas.y)meas.y = subjMeas.y;
			}
			
			//TODO: should we mark _measureFlag as valid
			if(_measurementsChanged && (_measurements.x!=oldMeasWidth || _measurements.y!=oldMeasHeight)){
				_measurementsChanged.perform(this,oldMeasWidth,oldMeasHeight);
			}
		}
		protected function measureSubject(subject:ILayoutSubject, subjMeas:Point):void{
			// override me
		}
		protected function layoutSubject(subject:ILayoutSubject, subjMeas:Point=null):void{
			// override me
		}
	}
}