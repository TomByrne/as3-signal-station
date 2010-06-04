package org.farmcode.sodalityPlatformEngine.parallax.advice
{
	import au.com.thefarmdigital.parallax.IParallaxDisplay;
	
	import org.farmcode.sodality.advice.Advice;
	import org.farmcode.sodalityLibrary.core.adviceTypes.IRevertableAdvice;
	import org.farmcode.sodalityPlatformEngine.parallax.adviceTypes.IAddManyParallaxDisplaysAdvice;
	
	public class AddManyParallaxDisplaysAdvice extends Advice implements IAddManyParallaxDisplaysAdvice, IRevertableAdvice
	{
		[Property(toString="true",clonable="true")]
		public function get parallaxDisplays():Array{
			return _parallaxDisplays;
		}
		public function set parallaxDisplays(value:Array):void{
			_parallaxDisplays = value;
		}
		
		[Property(toString="true",clonable="true")]
		public function get doRevert():Boolean{
			return _doRevert;
		}
		public function set doRevert(value:Boolean):void{
			_doRevert = value;
		}
		
		private var _doRevert:Boolean = true;
		private var _parallaxDisplays:Array;
		
		public function AddManyParallaxDisplaysAdvice(parallaxDisplays:Array=null){
			this.parallaxDisplays = parallaxDisplays;
		}
		public function get revertAdvice(): Advice{
			return new RemoveManyParallaxDisplaysAdvice(parallaxDisplays); 
		}
	}
}