package org.farmcode.display.layout.relative
{
	import flash.display.Stage;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import org.farmcode.display.assets.IDisplayAsset;
	import org.farmcode.display.assets.IStageAsset;
	import org.farmcode.display.core.IView;
	import org.farmcode.display.layout.ILayoutSubject;
	import org.farmcode.display.layout.stage.StageFillLayout;
	
	public class RelativeLayout extends StageFillLayout
	{
		private static const ORIGIN:Point = new Point();
		
		public function RelativeLayout(scopeView:IView=null, stage:IStageAsset=null){
			super(scopeView, stage);
		}
		public function update():void{
			invalidate();
		}
		override protected function layoutSubject(subject:ILayoutSubject, subjMeas:Point=null):void{
			var subMeas:Point = subject.measurements;
			var layoutInfo:IRelativeLayoutInfo = (subject.layoutInfo as IRelativeLayoutInfo);
			if(layoutInfo){
				var castView:IView = (subject as IView);
				if(!stage && castView && castView.asset.stage){
					stage = castView.asset.stage;
				}
				
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
					if(width>_displayPosition.width){
						width = _displayPosition.width;
					}
					if(transPoint.x<subMeas.x+_displayPosition.x){
						transPoint.x = subMeas.x+_displayPosition.x;
					}else if(transPoint.x>subMeas.x+_displayPosition.x+_displayPosition.width-width){
						transPoint.x = subMeas.x+_displayPosition.x+_displayPosition.width-width;
					}
					if(height>_displayPosition.height){
						height = _displayPosition.height;
					}
					if(transPoint.y<subMeas.y+_displayPosition.y){
						transPoint.y = subMeas.y+_displayPosition.y;
					}else if(transPoint.y>subMeas.y+_displayPosition.y+_displayPosition.height-height){
						transPoint.y = subMeas.y+_displayPosition.y+_displayPosition.height-height;
					}
				}
				
				// translate to parent space (if possible)
				if(castView && castView.asset.parent){
					transPoint = castView.asset.parent.globalToLocal(transPoint);
				}
				subject.setDisplayPosition(transPoint.x,transPoint.y,width,height);
			}
		}
	}
}