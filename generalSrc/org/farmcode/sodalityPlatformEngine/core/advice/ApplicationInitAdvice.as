package org.farmcode.sodalityPlatformEngine.core.advice
{
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	import org.farmcode.hoborg.Cloner;
	import org.farmcode.sodality.advice.Advice;
	import org.farmcode.actLibrary.display.progress.actTypes.IExecutionProgressAct;
	import org.farmcode.sodalityLibrary.external.siteStream.adviceTypes.IResolvePathsAdvice;
	import org.farmcode.sodalityPlatformEngine.core.IApplicationData;
	import org.farmcode.sodalityPlatformEngine.core.adviceTypes.IApplicationInitAdvice;

	public class ApplicationInitAdvice extends Advice implements IApplicationInitAdvice, IExecutionProgressAct, IResolvePathsAdvice
	{
		[Property(toString="true",clonable="true")]
		public function get appBounds():Rectangle{
			return _appBounds;
		}
		public function set appBounds(value:Rectangle):void{
			_appBounds = value;
		}
		[Property(toString="true",clonable="true")]
		public function get message():String{
			return _message;
		}
		public function set message(value:String):void{
			_message = value;
		}
		public function get applicationData():IApplicationData{
			return _applicationData;
		}
		public function get resolvePaths():Array{
			return [""];
		}
		public function set resolvedObjects(value:Dictionary):void{
			Cloner.setPropertyInClones(this,"resolvedObjects",value);
			_applicationData = value[""];
		}
		
		private var _appBounds:Rectangle;
		private var _message:String;
		private var _applicationData:IApplicationData;
		
		public function ApplicationInitAdvice(message:String=null, appBounds:Rectangle=null)
		{
			this.appBounds = appBounds;
			this.message = message;
		}
		
	}
}