package org.farmcode.sodalityPlatformEngine.parallax.advice
{
	import flash.utils.Dictionary;
	
	import org.farmcode.hoborg.Cloner;
	import org.farmcode.sodality.advice.Advice;
	import org.farmcode.sodalityLibrary.external.siteStream.adviceTypes.IResolvePathsAdvice;
	import org.farmcode.sodalityPlatformEngine.parallax.CameraSettings;
	import org.farmcode.sodalityPlatformEngine.parallax.adviceTypes.IChangeCameraSettingsAdvice;

	public class ChangeCameraSettingsAdvice extends Advice implements IChangeCameraSettingsAdvice, IResolvePathsAdvice
	{
		
		[Property(toString="true",clonable="true")]
		public function get cameraSettings():CameraSettings{
			return _cameraSettings;
		}
		public function set cameraSettings(value:CameraSettings):void{
			_cameraSettings = value;
		}
		
		[Property(toString="true",clonable="true")]
		public function get cameraSettingsPath():String{
			return _cameraSettingsPath;
		}
		public function set cameraSettingsPath(value:String):void{
			_cameraSettingsPath = value;
		}
		
		private var _cameraSettingsPath:String;
		private var _cameraSettings:CameraSettings;
		
		public function ChangeCameraSettingsAdvice(cameraSettingsPath: String = null, cameraSettings: CameraSettings = null){
			this.cameraSettingsPath = cameraSettingsPath;
			this.cameraSettings = cameraSettings;
		}
		public function get resolvePaths():Array{
			return _cameraSettings?[]:[_cameraSettingsPath];
		}
		public function set resolvedObjects(value:Dictionary):void{
			Cloner.setPropertyInClones(this,"resolvedObjects",value);
			var cameraSettings:CameraSettings = value[_cameraSettingsPath];
			if(cameraSettings)this.cameraSettings = cameraSettings;
		}
	}
}