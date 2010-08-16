package org.farmcode.display.parallax
{
	import org.farmcode.display.parallax.depthSorting.IDepthSorter;
	import org.farmcode.display.parallax.depthSorting.ZPositionDepthSorter;
	import org.farmcode.display.parallax.events.ParallaxEvent;
	import org.farmcode.display.parallax.modifiers.DisplayHider;
	import org.farmcode.display.parallax.modifiers.IParallaxModifier;
	
	import flash.events.Event;
	import flash.utils.Dictionary;
	
	public class LayeredParallax extends Parallax
	{
		private var _depthDict:Dictionary = new Dictionary();
		private var _layerDict:Dictionary = new Dictionary();
		private var _invalidLayers:Dictionary = new Dictionary();
		private var layerSorter: IDepthSorter;
		private var childModifiers:Array;
		protected var _displayHider:DisplayHider;
		
		public function LayeredParallax(){
			super();
			
			this.layerSorter = new ZPositionDepthSorter();
			_displayHider = new DisplayHider(scrollRect)
			childModifiers = [_displayHider];
		}
		override public function removeAllChildren():void{
			for each(var layer:ParallaxLayer in _depthDict){
				layer.removeAllParallaxChildren();
			}
			_depthDict = new Dictionary();
			_layerDict = new Dictionary();
			_invalidLayers = new Dictionary();
			super.removeAllChildren();
		}
		override public function addChild(parallaxDisplay:IParallaxDisplay):void{
			if(layerElligible(parallaxDisplay)){
				parallaxDisplay.addEventListener(ParallaxEvent.POSITION_CHANGED,onChildPosChange);
				parallaxDisplay.addEventListener(ParallaxEvent.DEPTH_CHANGED,onChildDepthChange);
				checkLayer(parallaxDisplay);
			}else{
				super.addChild(parallaxDisplay);
			}
		}
		override public function removeChild(parallaxDisplay:IParallaxDisplay):void{
			var parentLayer:ParallaxLayer = (parallaxDisplay.parallaxParent as ParallaxLayer);
			if(parentLayer && _layerDict[parentLayer]!=null && layerElligible(parallaxDisplay)){
				parallaxDisplay.removeEventListener(ParallaxEvent.POSITION_CHANGED,onChildPosChange);
				parallaxDisplay.removeEventListener(ParallaxEvent.DEPTH_CHANGED,onChildDepthChange);
				removeItemFromLayer(parallaxDisplay,parentLayer);
			}else{
				super.removeChild(parallaxDisplay);
				if(_layerDict[parallaxDisplay]!=null){
					removeLayer(parallaxDisplay as ParallaxLayer);
				}
			}
		}
		protected function removeItemFromLayer(parallaxDisplay:IParallaxDisplay, layer:ParallaxLayer):void{
			layer.removeParallaxChild(parallaxDisplay);
			layer.layerContainer.removeChild(parallaxDisplay.display);
			if(!layer.parallaxChildren.length){
				removeLayer(layer);
			}
		}
		protected function removeLayer(layer:ParallaxLayer):void{
			for each(var child:IParallaxDisplay in layer.parallaxChildren){
				super.removeChild(child);
			}
			layer.removeAllParallaxChildren();
			delete _depthDict[layer.position.z];
			delete _layerDict[layer];
			delete _invalidLayers[layer];
			super.removeChild(layer);
		}
		override protected function assessContainer():void{
			super.assessContainer();
			_displayHider.screenRect = scrollRect;
			_camera.screenRect = scrollRect;
		}
		protected function layerElligible(parallaxDisplay:IParallaxDisplay):Boolean{
			var cast:ILayeredParallaxDisplay = (parallaxDisplay as ILayeredParallaxDisplay);
			if(cast){
				return cast.useLayer;
			}
			return false;
		}
		protected function roundDepth(depth:Number):Number{
			//return (depth%1?int(depth+0.5):depth); // this doesn't work for negative numbers
			return Math.round(depth);
		}
		protected function checkLayer(item:IParallaxDisplay):void{
			var parentLayer:ParallaxLayer = (item.parallaxParent as ParallaxLayer);
			if(!parentLayer || _layerDict[parentLayer]==null){
				parentLayer = null;
			}
			if(layerElligible(item)){
				var destDepth:Number = roundDepth(item.position.z)
				var layer:ParallaxLayer = _depthDict[destDepth];
				if(!layer){
					if(parentLayer && parentLayer.parallaxChildren.length==1){
						delete _depthDict[parentLayer.position.z];
						layer = _depthDict[destDepth] = parentLayer;
					}else{
						layer = createLayer();
						_depthDict[destDepth] = layer;
						super.addChild(layer);
					}
					_layerDict[layer] = destDepth;
					layer.position.z = destDepth;
				}
				if(layer!=parentLayer){
					if(parentLayer){
						parentLayer.removeParallaxChild(item);
						parentLayer.layerContainer.removeChild(item.display);
					}
					if (item.display != layer.display)
					{
						layer.addParallaxChild(item);
						layer.layerContainer.addChild(item.display);
					}
				}
				setDisplayPosition(item);
				_invalidLayers[layer] = true;
			}else if(parentLayer){
				// free from layer
				removeItemFromLayer(item,parentLayer);
				addChild(item);
			}
		}
		override protected function onChildPosChange(e:Event):void{
			var item:IParallaxDisplay = (e.target as IParallaxDisplay);
			if(layerElligible(item)){
				setDisplayPosition(item);
			}else{
				super.onChildPosChange(e);
			}
		}
		protected function setDisplayPosition(item:IParallaxDisplay):void{
			if(_camera.rounding){
				item.display.x = (item.position.x-(item.position.x%1));
				item.display.y = (item.position.y-(item.position.y%1));
			}else{
				item.display.x = item.position.x;
				item.display.y = item.position.y;
			}
		}
		override protected function onChildDepthChange(e:Event):void{
			var item:IParallaxDisplay = (e.target as IParallaxDisplay);
			if (item.display)
			{
				checkLayer(item);
				if(!layerElligible(item)){
					super.onChildDepthChange(e);
				}
			}
		}
		override public function render():void{
			super.render();
			for each(var layer:ParallaxLayer in _depthDict){
				if(_invalidLayers[layer]){
					organiseDepths(layer.parallaxChildren, layer.layerContainer, this.layerSorter);
				}
				for each(var child:IParallaxDisplay in layer.parallaxChildren){
					_renderItem(child, childModifiers);
				}
			}
			_invalidLayers = new Dictionary();
		}
		override protected function modifyContainer():void{
			super.modifyContainer();
			for each(var modifier:IParallaxModifier in childModifiers){
				modifier.modifyContainer(_container);
			}
		}
		protected function createLayer():ParallaxLayer{
			var ret:ParallaxLayer = new ParallaxLayer();
			return ret;
		}
		
	}
}