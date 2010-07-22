package org.farmcode.display.containers.accordion
{
	import flash.utils.Dictionary;
	
	import org.farmcode.display.constants.Direction;
	import org.farmcode.display.containers.AbstractList;
	import org.farmcode.display.core.ILayoutView;
	import org.farmcode.display.layout.accordion.AccordionLayout;
	import org.farmcode.display.layout.grid.RendererGridLayout;
	import org.farmcode.instanceFactory.SimpleInstanceFactory;
	
	public class AbstractAccordionView extends AbstractList
	{
		private const ACCORDION_PANEL:String = "accordionPanel";
		
		public function get allowMultipleOpen():Boolean{
			return _allowMultipleOpen;
		}
		public function set allowMultipleOpen(value:Boolean):void{
			if(_allowMultipleOpen!=value){
				_allowMultipleOpen = value;
				if(!_allowMultipleOpen){
					for each(var minRenderer:IAccordionRenderer in _minRenderers){
						if(minRenderer.booleanValue && minRenderer!=_lastOpened){
							minRenderer.setOpen(false);
						}
					}
				}
			}
		}
		
		public function get gap():Number{
			var ret:Number = _layout.verticalGap;
			return _layout.horizontalGap==ret?ret:NaN;
		}
		public function set gap(value:Number):void{
			_layout.horizontalGap = value;
			_layout.verticalGap = value;
		}
		
		private var _allowMultipleOpen:Boolean;
		private var _minRenderers:Array = [];
		private var _lastOpened:IAccordionRenderer;
		protected var _accordionLayout:AccordionLayout;
		
		public function AbstractAccordionView(){
			_dataField = "data";
		}
		
		override protected function createAssumedFactory():void{
			_assumedRendererFactory = new SimpleInstanceFactory(AccordionRenderer);
			_assumedRendererFactory.useChildFactories = true;
			_assumedRendererFactory.instanceProperties = new Dictionary();
			_assumedRendererFactory.instanceProperties["asset"] = _assumedRendererAsset.getCloneFactory();
		}
		override protected function createLayout():void{
			_accordionLayout = new AccordionLayout();
			_accordionLayout.scopeView = this;
			_layout = _accordionLayout;
			_layout.equaliseCellHeights = true;
			_layout.equaliseCellWidths = true;
		}
		override protected function assumedRendererAssetName() : String{
			return ACCORDION_PANEL;
		}
		override protected function onAddRenderer(layout:RendererGridLayout, renderer:ILayoutView) : void{
			super.onAddRenderer(layout, renderer);
			var minSubject:IAccordionRenderer = (renderer as IAccordionRenderer);
			if(minSubject){
				minSubject.userChangedOpen.addHandler(onOpenChange);
				_minRenderers.push(minSubject);
			}
		}
		override protected function onRemoveRenderer(layout:RendererGridLayout, renderer:ILayoutView) : void{
			super.onRemoveRenderer(layout, renderer);
			var minSubject:IAccordionRenderer = (renderer as IAccordionRenderer);
			if(minSubject){
				minSubject.userChangedOpen.removeHandler(onOpenChange);
				var index:int = _minRenderers.indexOf(minSubject);
				_minRenderers.splice(index,1);
				if(_lastOpened==minSubject){
					_lastOpened = null;
				}
			}
		}
		
		protected function onOpenChange(from:IAccordionRenderer):void{
			if(from.booleanValue){
				_lastOpened = from;
				if(!_allowMultipleOpen){
					for each(var minRenderer:IAccordionRenderer in _minRenderers){
						if(minRenderer.booleanValue && minRenderer!=from){
							minRenderer.setOpen(false);
						}
					}
				}
			}
		}
	}
}