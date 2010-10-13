package org.tbyrne.display.parallax
{
	import org.tbyrne.display.parallax.depthSorting.IDepthSorter;
	import org.tbyrne.display.parallax.modifiers.IParallaxModifier;
	
	import flash.display.DisplayObjectContainer;
	import flash.utils.Dictionary;
	
	public class AbstractParallax
	{
		protected var _container:DisplayObjectContainer;
		protected var _modifiers:Array;
		protected var _depthSorter:IDepthSorter;
		protected var directChildren:Array = [];
		protected var childrenDict:Dictionary = new Dictionary();
		
		public function AbstractParallax(){
			this._modifiers = new Array();
		}
		protected function _addChild(parallaxDisplay:IParallaxDisplay):void{
			if(childrenDict[parallaxDisplay])throw new Error("Item " + parallaxDisplay + " has already been added to the Parallax");
			directChildren.push(parallaxDisplay);
			childrenDict[parallaxDisplay] = true;
		}
		protected function _removeChild(parallaxDisplay:IParallaxDisplay):void{
			if(childrenDict[parallaxDisplay]){
				var index:Number = directChildren.indexOf(parallaxDisplay);
				if(parallaxDisplay.display.parent==_container)_container.removeChild(parallaxDisplay.display);
				directChildren.splice(index,1);
				delete childrenDict[parallaxDisplay];
			}
		}
		protected function _renderAll():void{
			modifyContainer();
			var length:int = directChildren.length;
			for(var i:int=0; i<length; ++i){
				var item:IParallaxDisplay = directChildren[i];
				_renderItem(item, _modifiers);
				_parentItem(item);
			}
			organiseDepths(directChildren, _container, this._depthSorter);
		}
		protected function modifyContainer():void{
			for each(var modifier:IParallaxModifier in _modifiers){
				modifier.modifyContainer(_container);
			}
		}
		protected function _parentItem(item:IParallaxDisplay):void{
			if(item.display && item.display.parent!=_container){
				if(item.display.parent)item.display.parent.removeChild(item.display);
				_container.addChild(item.display);
			}
		}
		protected function organiseDepths(items:Array, container:DisplayObjectContainer, 
			targetSorter: IDepthSorter, sortOptions: uint = 2):void{
			var child:IParallaxDisplay;
			var depths:Array = items.sort(targetSorter.depthSort, sortOptions);
			var length:int = depths.length;
			var skip:int = 0;
			for(var i:int=0; i<length; ++i){
				child = depths[i];
				if(!child.display){
					++skip;
				}else if (container.getChildIndex(child.display) != i){
					container.setChildIndex(child.display,i-skip);
				}
			}
		}
		protected function _renderItem(item:IParallaxDisplay, modifiers:Array):void{
			if(item.display){
				for each(var modifier:IParallaxModifier in modifiers){
					modifier.modifyItem(item,_container);
				}
			}
		}
	}
}