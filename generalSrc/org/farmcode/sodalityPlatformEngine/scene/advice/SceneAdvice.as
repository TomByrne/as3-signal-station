package org.farmcode.sodalityPlatformEngine.scene.advice
{
	import flash.utils.Dictionary;
	
	import org.farmcode.hoborg.Cloner;
	import org.farmcode.sodality.advice.Advice;
	import org.farmcode.sodalityLibrary.external.siteStream.adviceTypes.ILookupObjectPathAdvice;
	import org.farmcode.sodalityLibrary.external.siteStream.adviceTypes.IResolvePathsAdvice;
	import org.farmcode.sodalityPlatformEngine.scene.IScene;
	import org.farmcode.sodalityPlatformEngine.scene.SceneDetails;

	public class SceneAdvice extends Advice implements IResolvePathsAdvice, ILookupObjectPathAdvice
	{
		public function get scene(): IScene{
			return _sceneDetails?_sceneDetails.scene:null;
		}
		[Property(toString="true",clonable="true")]
		public function get sceneDetails():SceneDetails{
			return _sceneDetails;
		}
		public function set sceneDetails(value:SceneDetails):void{
			_sceneDetails = value;
		}
		
		[Property(toString="true",clonable="true")]
		public function get sceneDetailsPath(): String{
			return _sceneDetailsPath;
		}
		public function set sceneDetailsPath(value: String): void{
			_sceneDetailsPath = value;
		}
		
		public function get resolvePaths():Array{
			return sceneDetails?[]:[_sceneDetailsPath];
		}
		public function set resolvedObjects(value:Dictionary):void{
			Cloner.setPropertyInClones(this,"resolvedObjects",value);
			var sceneDetails:SceneDetails = value[_sceneDetailsPath];
			if(sceneDetails)this.sceneDetails = sceneDetails;
		}
		public function get lookupObject():Object{
			return sceneDetails;
		}
		public function set lookupObjectPath(value:String):void{
			_sceneDetailsPath = value;
		}
		
		protected var _sceneDetailsPath:String;
		private var _sceneDetails:SceneDetails;
		
		public function SceneAdvice(sceneDetailsPath: String = null, sceneDetails: SceneDetails = null)
		{
			super();
			
			this.sceneDetails = sceneDetails;
			this.sceneDetailsPath = sceneDetailsPath;
		}
		
	}
}