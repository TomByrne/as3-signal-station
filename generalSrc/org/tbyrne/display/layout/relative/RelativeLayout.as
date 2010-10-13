package org.tbyrne.display.layout.relative
{
	import flash.geom.Point;
	
	import org.tbyrne.display.core.IView;
	import org.tbyrne.display.layout.ILayoutSubject;
	import org.tbyrne.display.layout.stage.StageFillLayout;
	
	public class RelativeLayout extends StageFillLayout
	{
		private static const ORIGIN:Point = new Point();
		
		public function RelativeLayout(scopeView:IView=null){
			super(scopeView);
		}
		// TODO:get rid of this
		public function update():void{
			invalidateSize();
		}
		override protected function layoutSubject(subject:ILayoutSubject, subjMeas:Point=null):void{
			var subMeas:Point = subject.measurements;
			var layoutInfo:IRelativeLayoutInfo = (subject.layoutInfo as IRelativeLayoutInfo);
			if(layoutInfo){
				var castView:IView = (subject as IView);
				
				// get point in global space
				var transPoint:Point = layoutInfo.relativeTo.localToGlobal(ORIGIN);
				
				// offset
				if(!isNaN(layoutInfo.relativeOffsetX)){
					transPoint.x  += layoutInfo.relativeOffsetX;
				}
				if(!isNaN(layoutInfo.relativeOffsetY)){
					transPoint.y  += layoutInfo.relativeOffsetY;
				}
				
				var width:Number = subMeas.x;
				var height:Number = subMeas.y;
				
				// constrain size
				if(!isNaN(layoutInfo.minWidth) && width<layoutInfo.minWidth){
					width = layoutInfo.minWidth;
				}
				if(!isNaN(layoutInfo.maxWidth) && width>layoutInfo.maxWidth){
					width = layoutInfo.maxWidth;
				}
				if(!isNaN(layoutInfo.minHeight) && height<layoutInfo.minHeight){
					height = layoutInfo.minHeight;
				}
				if(!isNaN(layoutInfo.maxHeight) && height>layoutInfo.maxHeight){
					height = layoutInfo.maxHeight;
				}
				
				// fit into screen (if applicable)
				if(layoutInfo.keepWithinStageBounds && stage){
					if(width>_size.x){
						width = _size.x;
					}
					if(transPoint.x<_position.x){
						transPoint.x = _position.x;
					}else if(transPoint.x>_position.x+_size.x-width){
						transPoint.x = _position.x+_size.x-width;
					}
					if(height>_size.y){
						height = _size.y;
					}
					if(transPoint.y<_position.y){
						transPoint.y = _position.y;
					}else if(transPoint.y>_position.y+_size.y-height){
						transPoint.y = _position.y+_size.y-height;
					}
				}
				
				// translate to parent space (if possible)
				if(castView && castView.asset.parent){
					transPoint = castView.asset.parent.globalToLocal(transPoint);
				}
				subject.setPosition(transPoint.x,transPoint.y);
				subject.setSize(width,height);
			}
		}
	}
}