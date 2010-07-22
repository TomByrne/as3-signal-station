package org.farmcode.display.layout.frame
{
	import flash.geom.Rectangle;
	
	import org.farmcode.display.core.IView;
	import org.farmcode.display.layout.AbstractLayout;
	import org.farmcode.display.layout.ILayoutSubject;
	import org.farmcode.display.layout.getMarginAffectedArea;
	import org.farmcode.display.utils.DisplayFramer;

	public class FrameLayout extends AbstractLayout
	{
		protected var marginAffectedPosition:Rectangle = new Rectangle();
		protected var marginRect:Rectangle = new Rectangle();
		
		public function FrameLayout(scopeView:IView){
			super(scopeView);
		}
		override protected function drawSubject(subject:ILayoutSubject) : void{
			var cast:IFrameLayoutInfo = (subject.layoutInfo as IFrameLayoutInfo);
			if(cast){
				
				getMarginAffectedArea(_displayPosition, subject.layoutInfo, marginAffectedPosition, marginRect);
				
				var framed:Rectangle = DisplayFramer.frame(subject.displayMeasurements,marginAffectedPosition,cast.anchor,cast.scaleXPolicy,cast.scaleYPolicy,cast.fitPolicy);
				subject.setDisplayPosition(framed.x,framed.y,framed.width,framed.height);
				
				var subMeas:Rectangle = subject.displayMeasurements;
				if(subMeas){
					addToMeas(subMeas.x-marginRect.x,
						subMeas.y-marginRect.y,
						subMeas.width+marginRect.x+marginRect.width,
						subMeas.height+marginRect.y+marginRect.height);
				}
			}else{
				super.drawSubject(subject);
			}
		}
	}
}