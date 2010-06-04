package org.farmcode.sodalityLibrary.display.visualSockets.plugs.containers
{
	import flash.display.DisplayObject;
	
	import org.farmcode.display.behaviour.containers.accordion.AccordionView;
	import org.farmcode.instanceFactory.IInstanceFactory;
	import org.farmcode.sodality.advice.IAdvice;
	import org.farmcode.sodality.advisors.DynamicAdvisor;
	import org.farmcode.sodalityLibrary.display.visualSockets.plugs.AbstractPlugDisplayProxy;
	
	public class AccordionPlug extends AbstractPlugDisplayProxy
	{
		public function get rendererFactory():IInstanceFactory{
			return accordionView.rendererFactory;
		}
		public function set rendererFactory(value:IInstanceFactory):void{
			accordionView.rendererFactory = value;
		}
		public function get rendererSocketProperty():String{
			return _rendererSocketProperty;
		}
		public function set rendererSocketProperty(value:String):void{
			_rendererSocketProperty = value;
		}
		public function get rendererLabelProperty():String{
			return _rendererLabelProperty;
		}
		public function set rendererLabelProperty(value:String):void{
			_rendererLabelProperty = value;
		}
		override public function set asset(value:DisplayObject):void{
			super.asset = value;
			_dynamicAdvisor.advisorDisplay = value;
		}
		public function get maximiseContainerSize():Boolean{
			return accordionView.maximiseContainerSize;
		}
		public function set maximiseContainerSize(value:Boolean):void{
			accordionView.maximiseContainerSize = value;
		}
		public function get gap():Number{
			return accordionView.gap;
		}
		public function set gap(value:Number):void{
			accordionView.gap = value
		}
		
		private var accordionView:AccordionView;
		private var _rendererSocketProperty:String = "childView";
		private var _rendererLabelProperty:String = "title";
		private var _dynamicAdvisor:DynamicAdvisor;
		
		public function AccordionPlug(){
			accordionView = new AccordionView();
			super(accordionView);
			_dynamicAdvisor = new DynamicAdvisor();
		}
		override protected function commitData(cause:IAdvice=null) : void{
			accordionView.data = getDataProvider();
		}
		override protected function uncommitData(cause:IAdvice=null) : void{
			accordionView.data = null;
		}
	}
}