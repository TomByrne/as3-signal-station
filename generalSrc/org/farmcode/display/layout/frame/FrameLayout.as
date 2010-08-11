package org.farmcode.display.layout.frame
{
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import org.farmcode.display.core.IView;
	import org.farmcode.display.layout.AbstractLayout;
	import org.farmcode.display.layout.ILayoutSubject;
	import org.farmcode.display.layout.getMarginAffectedArea;
	import org.farmcode.display.utils.DisplayFramer;

	
	/*
	TODO: we have problems with layouts, they need to work better in relation to their invalidation
	and measurement, measurement waits a frame in most/all cases, this won't do.
	Also, drawing and invalidation needs to be rethought.
	
	*/
	public class FrameLayout extends AbstractLayout
	{
		protected var marginAffectedPosition:Rectangle = new Rectangle();
		protected var marginRect:Rectangle = new Rectangle();
		
		public function FrameLayout(scopeView:IView=null){
			super(scopeView);
		}
		override protected function drawSubject(subject:ILayoutSubject) : void{
			var cast:IFrameLayoutInfo = (subject.layoutInfo as IFrameLayoutInfo);
			if(cast){
				
				getMarginAffectedArea(_displayPosition, subject.layoutInfo, marginAffectedPosition, marginRect);
				
				var subMeas:Point = subject.measurements;
				var framed:Rectangle = DisplayFramer.frame(subMeas.x,subMeas.y,marginAffectedPosition,cast.anchor,cast.scaleXPolicy,cast.scaleYPolicy,cast.fitPolicy);
				subject.setDisplayPosition(framed.x,framed.y,framed.width,framed.height);
				
				if(subMeas){
					addToMeas(subMeas.x+marginRect.x+marginRect.width,
								subMeas.y+marginRect.y+marginRect.height);
				}
			}else{
				super.drawSubject(subject);
			}
		}
	}
}