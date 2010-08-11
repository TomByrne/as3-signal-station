package org.farmcode.display.layout
{
	import org.farmcode.display.core.IView;
	
	public class AbstractCompositeLayout extends AbstractLayout
	{
		public function AbstractCompositeLayout(scopeView:IView){
			super(scopeView);
		}
		override protected function onSubjectMeasChanged(from:ILayoutSubject, oldWidth:Number, oldHeight:Number): void{
			doMeasurementsChanged();
		}
		override protected function draw() : void{
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
		protected function doLayout() : void{
			// override me
		}
	}
}