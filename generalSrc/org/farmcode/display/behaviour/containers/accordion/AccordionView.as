package org.farmcode.display.behaviour.containers.accordion
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	import org.farmcode.collections.ICollection;
	import org.farmcode.collections.IIterator;
	import org.farmcode.collections.linkedList.LinkedListConverter;
	import org.farmcode.display.behaviour.containers.ContainerView;
	import org.farmcode.display.constants.Direction;
	import org.farmcode.display.layout.ProxyLayoutSubject;
	import org.farmcode.display.layout.list.ListLayout;
	import org.farmcode.display.layout.list.ListLayoutInfo;
	import org.farmcode.instanceFactory.IInstanceFactory;
	
	public class AccordionView extends ContainerView
	{
		public function get rendererFactory():IInstanceFactory{
			return _rendererFactory;
		}
		public function set rendererFactory(value:IInstanceFactory):void{
			if(_rendererFactory!=value){
				_rendererFactory = value;
				_renderersInvalid = true;
				invalidate();
			}
		}
		
		public function get data():*{
			return _data;
		}
		public function set data(value:*):void{
			if(_data!=value){
				_data = value;
				var cast:ICollection = (value as ICollection);
				if(!cast){
					_dataProviderCollection = LinkedListConverter.fromNativeCollection(value);
				}else{
					_dataProviderCollection = cast;
				}
				_dataInvalid = true;
				invalidate();
			}
		}
		public function get maximiseContainerSize():Boolean{
			return _maximiseContainerSize;
		}
		public function set maximiseContainerSize(value:Boolean):void{
			if(_maximiseContainerSize!=value){
				_maximiseContainerSize = value;
				invalidate();
			}
		}
		public function get gap():Number{
			return _layout.gap;
		}
		public function set gap(value:Number):void{
			_layout.gap = value
		}
		public function get openIndex():int{
			return _openIndex;
		}
		/*public function get layout():ListLayout{
			return _layout;
		}*/
		
		private var _dataProviderCollection:ICollection;
		private var _data:*;
		
		private var _maximiseContainerSize:Boolean = true;
		private var _rendererFactory:IInstanceFactory;
		
		private var _layout:ListLayout = new ListLayout();
		
		private var _renderersInvalid:Boolean;
		private var _dataInvalid:Boolean;
		
		private var _renderers:Dictionary;
		private var _proxyLayouts:Dictionary;
		private var _renderersCreated:int = 0;
		
		private var _prevOpenContainer:int = 0;
		private var _openIndex:int = 0;
		
		private var _container:Sprite = new Sprite();
		
		public function AccordionView(asset:DisplayObject=null){
			super(asset);
			_layout.equaliseCellWidths = true;
			_layout.equaliseCellHeights = true;
		}
		protected function onRendererSelect(renderer:IAccordionRenderer):void{
			for(var i:* in _renderers){
				if(_renderers[i]==renderer){
					var oldOpen:IAccordionRenderer = (_renderers[_openIndex]);
					if(oldOpen!=renderer){
						_openIndex = i;
						oldOpen.open = false;
						renderer.open = true;
					}
					break;
				}
			}
		}
		override protected function bindToAsset() : void{
			super.bindToAsset();
			containerAsset.addChild(_container);
		}
		override protected function unbindFromAsset() : void{
			super.unbindFromAsset();
			containerAsset.removeChild(_container);
		}
		
		override protected function draw() : void{
			super.draw();
			if(_rendererFactory && _dataProviderCollection){
				
				var renderer:IAccordionRenderer;
				var proxy:ProxyLayoutSubject;
				
				var i:int;
				if(_renderersInvalid){
					// remove all label renderers
					for(i=0; i<_renderersCreated; i++){
						renderer = _renderers[i];
						renderer.select.removeHandler(onRendererSelect);
						renderer.data = null;
						containerAsset.removeChild(renderer.asset);
						
						proxy = _proxyLayouts[i];
						proxy.layoutInfo = null;
						_layout.removeSubject(proxy);
					}
					_renderers = new Dictionary();
					_proxyLayouts = new Dictionary();
					_renderersCreated = 0;
					_renderersInvalid = false;
					_dataInvalid = true;
				}
				var iterator:IIterator;
				var data:*;
				if(_dataInvalid){
					i=0;
					iterator = _dataProviderCollection.getIterator();
					// create any additional label/container renderers
					while(data = iterator.next()){
						if(i>=_renderersCreated){
							renderer = _rendererFactory.createInstance();
							renderer.select.addHandler(onRendererSelect);
							renderer.accordionIndex = i;
							containerAsset.addChild(renderer.asset);
							_renderers[i] = renderer;
							
							proxy = new ProxyLayoutSubject(renderer);
							proxy.layoutInfo = new ListLayoutInfo(i);
							_proxyLayouts[i] = proxy;
							_layout.addSubject(proxy);
						}
						i++;
					}
					iterator.release();
					_dataInvalid = false;
					
					var j:int;
					// remove any excess renderers
					for(j = i; j<_renderersCreated; j++){
						renderer = _renderers[j];
						renderer.select.removeHandler(onRendererSelect);
						renderer.data = null;
						containerAsset.removeChild(renderer.asset);
						delete _renderers[j];
						
						proxy = _proxyLayouts[j];
						proxy.layoutInfo = null;
						_layout.removeSubject(proxy);
						delete _proxyLayouts[j];
					}
					_renderersCreated = i;
				}
				
				var vert:Boolean;
				var maxOpenSize:Number;
				var gap:Number = _layout.gap;
				var stackDim:String;
				var stackCoord:String;
				if(_layout.direction==Direction.VERTICAL){
					vert = true;
					maxOpenSize = displayPosition.height;
					stackDim = "height";
					stackCoord = "y";
				}else{
					vert = false;
					maxOpenSize = displayPosition.width;
					stackDim = "width";
					stackCoord = "x";
				}
				// measure minimum renderer
				var minimum:Rectangle;
				i=0;
				iterator = _dataProviderCollection.getIterator();
				while(data = iterator.next()){
					renderer = _renderers[i];
					renderer.data = data;
					if(i!=_openIndex){
						minimum = renderer.minimumSize;
						maxOpenSize -= minimum[stackDim]+gap;
					}
					i++;
				}
				if(maxOpenSize<0)maxOpenSize = 0;
				iterator.release();
				
				// set renderer sizes
				var stack:Number = 0;
				//var measurements:Rectangle;
				for(i=0; i<_renderersCreated; i++){
					renderer = _renderers[i];
					minimum = renderer.minimumSize;
					//measurements = renderer.displayMeasurements;
					var open:Boolean = (i==_openIndex);
					renderer.open = open;
					var rendererSize:Number;
					if(open){
						rendererSize = maxOpenSize;
					}else{
						rendererSize = minimum[stackDim];
					}
					
					var openSize:Number = maxOpenSize;
					if(openSize<rendererSize){
						openSize = rendererSize;
					}
					if(!_maximiseContainerSize && openSize>rendererSize){
						openSize = rendererSize;
					}
					if(vert){
						renderer.setOpenSize(0,stack,displayPosition.width,openSize);
					}else{
						renderer.setOpenSize(stack,0,openSize,displayPosition.height);
					}
					stack += rendererSize;
				}
				_layout.setDisplayPosition(0,0,displayPosition.width,displayPosition.height);
			}
		}
	}
}