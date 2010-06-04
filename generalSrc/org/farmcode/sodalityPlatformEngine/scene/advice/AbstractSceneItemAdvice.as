package org.farmcode.sodalityPlatformEngine.scene.advice
{
	import flash.utils.Dictionary;
	
	import org.farmcode.hoborg.Cloner;
	import org.farmcode.sodality.advice.Advice;
	import org.farmcode.sodalityLibrary.external.siteStream.adviceTypes.IResolvePathsAdvice;
	import org.farmcode.sodalityPlatformEngine.scene.ISceneItem;
	
	public class AbstractSceneItemAdvice extends Advice implements IResolvePathsAdvice
	{		
		
		[Property(toString="true",clonable="true")]
		public function get sceneItem():ISceneItem{
			return _sceneItem;
		}
		public function set sceneItem(value:ISceneItem):void{
			_sceneItem = value;
		}
		
		[Property(toString="true",clonable="true")]
		public function get sceneItemPath():String{
			return _sceneItemPath;
		}
		public function set sceneItemPath(value:String):void{
			_sceneItemPath = value;
		}
		public function get resolvePaths():Array{
			return _sceneItem?[]:[_sceneItemPath];
		}
		public function set resolvedObjects(value:Dictionary):void{
			Cloner.setPropertyInClones(this,"resolvedObjects",value);
			var sceneItem:ISceneItem = value[_sceneItemPath];
			if(sceneItem)this.sceneItem = sceneItem;
		}
		
		protected var _sceneItemPath:String;
		private var _sceneItem:ISceneItem;
		
		public function AbstractSceneItemAdvice(sceneItemPath:String=null, sceneItem:ISceneItem=null){
			this.sceneItemPath = sceneItemPath;
			this.sceneItem = sceneItem;
		}
	}
}