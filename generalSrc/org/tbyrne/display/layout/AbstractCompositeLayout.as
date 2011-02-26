package org.tbyrne.display.layout
{
	import flash.geom.Point;
	
	import org.tbyrne.display.core.IView;
	
	public class AbstractCompositeLayout extends AbstractLayout
	{
		public function AbstractCompositeLayout(scopeView:IView){
			super(scopeView);
		}
		override protected function onSubjectMeasChanged(from:ILayoutSubject, oldWidth:Number, oldHeight:Number): void{
			invalidateMeasurements();
		}
		override protected function commitPos():void{
			invalidateSize();
		}
		override protected function commitSize():void{
			var doMeas:Boolean = (drawToMeasure() && _measurementsChanged);
			if(doMeas){
				var oldMeasWidth:Number = _measurements.x;
				var oldMeasHeight:Number = _measurements.y;
			}
			doLayout();
			if(doMeas && (_measurements.x!=oldMeasWidth || _measurements.y!=oldMeasHeight)){
				_measurementsChanged.perform(this,oldMeasWidth,oldMeasHeight);
			}
		}
		protected function get midDrawMeas() : Point{
			if(drawToMeasure())return _measurements;
			else return measurements;
		}
		protected function doLayout() : void{
			// override me
		}
	}
}