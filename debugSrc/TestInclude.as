package
{
	import flash.display.Sprite;
	
	import org.tbyrne.actLibrary.application.ConfiguredApplication;
	import org.tbyrne.actLibrary.application.VisualSocketApplication;
	import org.tbyrne.actLibrary.data.actions.ExternalLink;
	import org.tbyrne.actLibrary.data.actions.InternalLink;
	import org.tbyrne.actLibrary.display.transition.TransitionActor;
	import org.tbyrne.actLibrary.display.visualSockets.plugs.PlugDisplay;
	import org.tbyrne.actLibrary.display.visualSockets.plugs.controls.TextLabelButtonPlug;
	import org.tbyrne.actLibrary.display.visualSockets.plugs.controls.TextLabelPlug;
	import org.tbyrne.actLibrary.display.visualSockets.socketContainers.SocketCollectionContainer;
	import org.tbyrne.actLibrary.display.visualSockets.socketContainers.SocketCollectionContainerHelper;
	import org.tbyrne.actLibrary.display.visualSockets.socketContainers.SocketContainer;
	import org.tbyrne.actLibrary.sound.SoundActor;
	import org.tbyrne.actLibrary.sound.acts.AddSoundAct;
	import org.tbyrne.bezier.Bezier;
	import org.tbyrne.bezier.BezierPoint;
	import org.tbyrne.bezier.Path;
	import org.tbyrne.collections.utils.arraysEqual;
	import org.tbyrne.collections.utils.randomSort;
	import org.tbyrne.core.Application;
	import org.tbyrne.data.actions.Link;
	import org.tbyrne.data.operators.NumberRange;
	import org.tbyrne.debug.DebugManager;
	import org.tbyrne.debug.display.DebugItemRenderer;
	import org.tbyrne.debug.logging.ASDebuggerLogger;
	import org.tbyrne.debug.logging.XMLFileLogger;
	import org.tbyrne.display.assets.nativeAssets.NativeAssetFactory;
	import org.tbyrne.display.containers.AbstractList;
	import org.tbyrne.display.containers.ContainerView;
	import org.tbyrne.display.containers.MediaContainer;
	import org.tbyrne.display.containers.TabPanel;
	import org.tbyrne.display.containers.VideoContainer;
	import org.tbyrne.display.containers.accordion.AbstractAccordionView;
	import org.tbyrne.display.containers.accordionGrid.AccordionGridRenderer;
	import org.tbyrne.display.containers.accordionGrid.AccordionGridView;
	import org.tbyrne.display.controls.BufferBar;
	import org.tbyrne.display.controls.ScrollButtons;
	import org.tbyrne.display.controls.Slider;
	import org.tbyrne.display.controls.SliderButton;
	import org.tbyrne.display.controls.TextInput;
	import org.tbyrne.display.controls.TextLabelButton;
	import org.tbyrne.display.controls.popout.DropDownList;
	import org.tbyrne.display.controls.popout.PopoutDisplay;
	import org.tbyrne.display.controls.popout.PopoutList;
	import org.tbyrne.display.controls.toolTip.ToolTipAnnotator;
	import org.tbyrne.display.controls.toolTip.ToolTipDisplay;
	import org.tbyrne.display.controls.toolTip.ToolTipManager;
	import org.tbyrne.display.core.View;
	import org.tbyrne.display.layout.AbstractLayout;
	import org.tbyrne.display.layout.ProxyLayoutSubject;
	import org.tbyrne.display.layout.accordion.AccordionLayout;
	import org.tbyrne.display.layout.canvas.CanvasLayout;
	import org.tbyrne.display.layout.frame.FrameLayout;
	import org.tbyrne.display.layout.grid.AbstractGridLayout;
	import org.tbyrne.display.layout.grid.GridLayout;
	import org.tbyrne.display.layout.grid.RendererGridLayout;
	import org.tbyrne.display.layout.list.ListLayout;
	import org.tbyrne.display.layout.relative.RelativeLayout;
	import org.tbyrne.display.layout.stage.StageFillLayout;
	import org.tbyrne.display.parallax.modifiers.ParallaxCamera;
	import org.tbyrne.display.progress.AbstractProgressDisplay;
	import org.tbyrne.display.progress.SWFPreloaderFrame;
	import org.tbyrne.display.progress.SimpleProgressDisplay;
	import org.tbyrne.display.scrolling.MouseDragScroller;
	import org.tbyrne.display.scrolling.MouseWheelScroller;
	import org.tbyrne.display.transition.BlurTransition;
	import org.tbyrne.display.transition.CrossFadeTransition;
	import org.tbyrne.display.transition.ExposureTransition;
	import org.tbyrne.display.transition.IrisTransition;
	import org.tbyrne.display.transition.ShutterTransition;
	import org.tbyrne.display.transition.Transition;
	import org.tbyrne.display.transition.WipeTransition;
	import org.tbyrne.display.utils.FullscreenUtil;
	import org.tbyrne.display.utils.TopLayerManager;
	import org.tbyrne.display.validation.DisplayValidationFlag;
	import org.tbyrne.gateway.ServerProxy;
	import org.tbyrne.gateway.commands.CallMethodCommand;
	import org.tbyrne.gateways.FlashVarsGateway;
	import org.tbyrne.gateways.methodCalls.GetPropertyCall;
	import org.tbyrne.gateways.methodCalls.SetPropertyCall;
	import org.tbyrne.input.InputMediator;
	import org.tbyrne.input.items.InputGroup;
	import org.tbyrne.input.items.NotificationInputItem;
	import org.tbyrne.input.items.TogglableInputItem;
	import org.tbyrne.media.MediaProgressDisplayAdaptor;
	import org.tbyrne.media.image.GifSource;
	import org.tbyrne.media.video.ProgressiveVideoSource;
	import org.tbyrne.media.video.StreamingVideoSource;
	import org.tbyrne.media.video.VolumeMemory;
	import org.tbyrne.mediatorTypes.IMenuMediator;
	import org.tbyrne.reflection.ReflectionUtils;
	import org.tbyrne.sound.soundControls.CompositeSoundControl;
	import org.tbyrne.sound.soundControls.IntroOutroSoundControl;
	import org.tbyrne.sound.soundControls.SoundControl;
	import org.tbyrne.sound.soundControls.SoundTransformControl;
	import org.tbyrne.utils.DateFormat;

	public class TestInclude extends Sprite
	{
		public function TestInclude()
		{
			StreamingVideoSource;
			TopLayerManager;
			SocketContainer;
			InternalLink;
			ExternalLink;
			Link;
			ConfiguredApplication;
			NativeAssetFactory;
			VisualSocketApplication;
			VolumeMemory;
			ProgressiveVideoSource;
			TextLabelButton;
			TextLabelButtonPlug;
			SocketCollectionContainerHelper
			SocketCollectionContainer;
			TextLabelPlug;
			TransitionActor;
			Transition;
			AbstractLayout;
			CrossFadeTransition;
			BlurTransition;
			IrisTransition;
			ShutterTransition;
			WipeTransition;
			ExposureTransition;
			FrameLayout;
			StageFillLayout;
			CanvasLayout;
			AbstractGridLayout;
			RelativeLayout;
			RendererGridLayout;
			GridLayout;
			ListLayout;
			AbstractProgressDisplay;
			AccordionLayout;
			MediaContainer;
			AbstractList;
			SimpleProgressDisplay;
			AccordionGridRenderer;
			SWFPreloaderFrame;
			View;
			TextInput;
			ContainerView;
			ProxyLayoutSubject;
			MouseDragScroller;
			MouseWheelScroller;
			ScrollButtons;
			GifSource;
			PopoutDisplay;
			PlugDisplay;
			AbstractAccordionView;
			AccordionGridView;
			SoundActor
			SoundControl
			SoundTransformControl
			AddSoundAct
			CompositeSoundControl
			IntroOutroSoundControl
			TabPanel
			DropDownList
			PopoutList
			ToolTipManager
			arraysEqual([],[]);
			randomSort(null,null);
			ParallaxCamera;
			MediaProgressDisplayAdaptor;
			NumberRange;
			DateFormat;
			DebugManager;
			DebugItemRenderer;
			VideoContainer;
			Slider;
			BufferBar;
			ToolTipDisplay;
			SliderButton;
			ToolTipAnnotator;
			ServerProxy;
			CallMethodCommand;
			SetPropertyCall;
			GetPropertyCall;
			FlashVarsGateway;
			ASDebuggerLogger;
			FullscreenUtil;
			Path;
			Bezier;
			BezierPoint;
			DisplayValidationFlag;
			XMLFileLogger;
			Application;
			IMenuMediator;
			InputGroup;
			InputMediator;
			NotificationInputItem;
			TogglableInputItem;
			
			var type:Class= ReflectionUtils.getClassByName("flash.display.Sprite");
		}
	}
}