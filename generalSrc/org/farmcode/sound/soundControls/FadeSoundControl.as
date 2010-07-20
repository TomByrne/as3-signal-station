package org.farmcode.sound.soundControls
{
	import org.farmcode.tweening.LooseTween;
	
	import flash.events.Event;
	import flash.media.Sound;
	import flash.media.SoundTransform;
	
	import org.goasap.events.GoEvent;

	public class FadeSoundControl extends SoundControl
	{
		public function get fadeIn():Boolean{
			return _fadeIn;
		}
		public function set fadeIn(value:Boolean):void{
			_fadeIn = value;
		}
		public function get fadeOut():Boolean{
			return _fadeOut;
		}
		public function set fadeOut(value:Boolean):void{
			_fadeOut = value;
		}
		public function get fadeDuration():Number{
			return _fadeDuration;
		}
		public function set fadeDuration(value:Number):void{
			_fadeDuration = value;
		}
		public function get fadeEasing():Function{
			return _fadeEasing;
		}
		public function set fadeEasing(value:Function):void{
			_fadeEasing = value;
		}
		
		private var _fadeOut:Boolean 					= true;
		private var _fadeIn:Boolean 					= false;
		private var _fadeVolume:Number 					= 0;
		private var _fadeTween:LooseTween;
		private var _fadeDuration:Number				= 0.5;
		private var _fadeEasing:Function;
		
		public function FadeSoundControl(sound:Sound=null, loops:int=0){
			super(sound, loops);
		}
		
		override protected function intro():void{
			super.intro();
			if(this.fadeIn){
				tweenSound(_fadeVolume,1, onFinishIntro);
			}else{
				_fadeVolume = 1;
				applyVolume();
			}
		}
		override protected function outro():void{
			if(this.fadeOut){
				tweenSound(_fadeVolume,0,onFinishOutro);
			}else{
				_fadeVolume = 0;
				applyVolume();
			}
		}
		protected function tweenSound(from:Number, to:Number, onFinish:Function=null):void{
			clearTween()
			_fadeTween = new LooseTween({value:from},{value:to},_fadeEasing,_fadeDuration);
			_fadeTween.addEventListener(GoEvent.UPDATE,onTweenChange);
			_fadeTween.start();
			if(onFinish!=null)_fadeTween.addEventListener(GoEvent.COMPLETE, onFinish);
		}
		protected function onTweenChange(e:GoEvent):void{
			_fadeVolume = (e.target as LooseTween).target.value;
			applyVolume();
		}
		protected function onFinishIntro(e:Event):void{
			clearTween()
		}
		protected function onFinishOutro(e:Event):void{
			clearTween()
			clearCurrentChannel();
			this.dispatchFinished();
		}
		override protected function compileTransform():SoundTransform{
			var ret:SoundTransform = super.compileTransform();
			ret.volume *= _fadeVolume;
			return ret;
		}
		protected function clearTween():void{
			if(_fadeTween){
				_fadeTween.removeEventListener(GoEvent.UPDATE, onTweenChange);
				_fadeTween.removeEventListener(GoEvent.COMPLETE, onFinishIntro);
				_fadeTween.removeEventListener(GoEvent.COMPLETE, onFinishOutro);
				_fadeTween = null;
			}
		}
	}
}