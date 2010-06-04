package au.com.thefarmdigital.display
{
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;

	//[SWF(width="1000",height="700",backgroundColor="0xffffff",framerate="30")] // must be on subclass
	public class AbstractRoot extends Sprite
	{
		public function AbstractRoot(){
			super();
			if(stage){
				onAddedToStage();
			}else{
				addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			}
		}
		private function onAddedToStage(e:Event=null):void{
			if(e){
				removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			}
			initialise();
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.addEventListener(Event.RESIZE, onStageResize);
			onStageResize();
		}
		protected function initialise():void{
			// override me
		}
		private function onStageResize(e:Event=null):void{
			setSize(stage.stageWidth, stage.stageHeight);
		}
		protected function setSize(width:Number, height:Number):void{
			// override me
		}
	}
}