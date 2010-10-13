package org.tbyrne.display.layout.accordion
{
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	import org.tbyrne.display.constants.Direction;
	import org.tbyrne.display.core.ILayoutView;
	import org.tbyrne.display.core.IView;
	import org.tbyrne.display.layout.AbstractLayout;
	import org.tbyrne.display.layout.ILayoutSubject;
	import org.tbyrne.display.layout.IMinimisableLayoutSubject;
	import org.tbyrne.display.layout.grid.IGridLayoutSubject;
	import org.tbyrne.display.layout.grid.RendererGridLayout;
	
	//TODO: support a maximiseContainerSize property
	public class AccordionLayout extends RendererGridLayout
	{
		
		public function get accordionDirection():String{
			return _accordionDirection;
		}
		public function set accordionDirection(value:String):void{
			if(_accordionDirection!=value){
				_accordionDirection = value;
				_cellPosFlag.invalidate();
				invalidateSize();
			}
		}
		
		private var _accordionDirection:String = Direction.VERTICAL;
		
		private var _minSubjectsMeas:Dictionary = new Dictionary();
		private var _realMeas:Dictionary = new Dictionary();
		
		public function AccordionLayout(scopeView:IView=null){
			super(scopeView);
			flowDirection = Direction.VERTICAL;
			addRendererAct.addHandler(onRendererAdded);
			removeRendererAct.addHandler(onRendererRemoved);
		}
		protected function onRendererAdded(from:AccordionLayout, renderer:IMinimisableLayoutSubject):void{
			renderer.openFractChanged.addHandler(onOpenFractChanged);
		}
		protected function onRendererRemoved(from:AccordionLayout, renderer:IMinimisableLayoutSubject):void{
			renderer.openFractChanged.removeHandler(onOpenFractChanged);
		}
		protected function onOpenFractChanged(from:IMinimisableLayoutSubject) : void{
			invalidateSize();
		}
		override protected function rendererAdded(renderer:ILayoutSubject):void{
			super.rendererAdded(renderer);
			(renderer as IMinimisableLayoutSubject).minMeasurementsChanged.addHandler(onMinChanged);
		}
		override protected function rendererRemoved(renderer:ILayoutSubject):void{
			super.rendererRemoved(renderer);
			(renderer as IMinimisableLayoutSubject).minMeasurementsChanged.removeHandler(onMinChanged);
		}
		
		protected function onMinChanged(from:IMinimisableLayoutSubject) : void{
			var data:* = from[_dataField];
			delete _cellMeasCache[data];
			invalidateSize();
		}
		override protected function getChildMeasurement(key:*) : Point{
			if(key>=_dataCount){
				return null;
			}
			var data:* = _dataMap[key];
			var renderer:ILayoutSubject = _dataToRenderers[data];
			if(!renderer){
				if(!_protoRenderer){
					_protoRenderer = _rendererFactory.createInstance();
				}
				_protoRenderer[_dataField] = data;
				if(_setRendererDataAct)_setRendererDataAct.perform(this,_protoRenderer,data,_dataField);
				renderer = _protoRenderer;
			}
			var minRenderer:IMinimisableLayoutSubject = (renderer as IMinimisableLayoutSubject);
			
			var ret:Point = new Point();
			var min:Point = minRenderer.minMeasurements;
			var fullMeas:Point = renderer.measurements;
			_realMeas[key] = fullMeas;
			
			ret.x = min.x+(fullMeas.x-min.x)*minRenderer.openFract;
			ret.y = min.y+(fullMeas.y-min.y)*minRenderer.openFract;
			
			if(renderer==_protoRenderer){
				_protoRenderer[_dataField] = null;
				if(_setRendererDataAct)_setRendererDataAct.perform(this,_protoRenderer,null,_dataField);
			}
			return ret;
		}
		
		override protected function positionRenderer(key:*, length:int, breadth:int, x:Number, y:Number, width:Number, height:Number):void{
			var renderer:IMinimisableLayoutSubject = getChildRenderer(key,length,breadth) as IMinimisableLayoutSubject;
			var cast:IGridLayoutSubject = (renderer as IGridLayoutSubject);
			if(cast){
				cast[_lengthRendAxis.indexRef] = length;
				cast[_breadthRendAxis.indexRef] = breadth;
			}
			
			var posIndex:int = (key as int)*int(4);
			_positionCache[posIndex] = x;
			_positionCache[posIndex+1] = y;
			_positionCache[posIndex+2] = width;
			_positionCache[posIndex+3] = height;
			var coIndex:int = (key as int)*int(2);
			_coordCache[coIndex] = length;
			_coordCache[coIndex+1] = breadth;
			
			if(renderer){
				var fullMeas:Rectangle = _realMeas[key];
				if(_accordionDirection==Direction.VERTICAL){
					renderer.setPosition(x,y);
					renderer.setSize(width,fullMeas.height>height?fullMeas.height:height);
					renderer.setOpenArea(width,height);
				}else{
					renderer.setPosition(x,y);
					renderer.setSize(fullMeas.width>width?fullMeas.width:width,height);
					renderer.setOpenArea(width,height);
				}
			}
		}
	}
}