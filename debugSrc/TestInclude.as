package
{
	import org.farmcode.actLibrary.application.ConfiguredApplication;
	import org.farmcode.actLibrary.application.VisualSocketApplication;
	import org.farmcode.actLibrary.data.actions.ExternalLink;
	import org.farmcode.actLibrary.data.actions.InternalLink;
	import org.farmcode.actLibrary.display.errorPopup.ErrorPopupActor;
	import org.farmcode.actLibrary.display.popup.PopupActor;
	import org.farmcode.actLibrary.display.progress.ProgressIndicatorActor;
	import org.farmcode.actLibrary.display.transition.TransitionActor;
	import org.farmcode.actLibrary.display.visualSockets.plugs.PlugDisplay;
	import org.farmcode.actLibrary.display.visualSockets.plugs.controls.TextLabelButtonPlug;
	import org.farmcode.actLibrary.display.visualSockets.plugs.controls.TextLabelPlug;
	import org.farmcode.actLibrary.display.visualSockets.socketContainers.SocketCollectionContainer;
	import org.farmcode.actLibrary.display.visualSockets.socketContainers.SocketCollectionContainerHelper;
	import org.farmcode.actLibrary.display.visualSockets.socketContainers.SocketContainer;
	import org.farmcode.actLibrary.sound.SoundActor;
	import org.farmcode.actLibrary.sound.acts.AddSoundAct;
	import org.farmcode.collections.utils.arraysEqual;
	import org.farmcode.collections.utils.randomSort;
	import org.farmcode.data.actions.Link;
	import org.farmcode.data.operators.NumberRange;
	import org.farmcode.debug.DebugManager;
	import org.farmcode.debug.display.DebugItemRenderer;
	import org.farmcode.display.assets.nativeAssets.NativeAssetFactory;
	import org.farmcode.display.containers.AbstractList;
	import org.farmcode.display.containers.ContainerView;
	import org.farmcode.display.containers.MediaContainer;
	import org.farmcode.display.containers.ScrollWrapper;
	import org.farmcode.display.containers.TabPanel;
	import org.farmcode.display.containers.VideoContainer;
	import org.farmcode.display.containers.accordion.AbstractAccordionView;
	import org.farmcode.display.containers.accordionGrid.AccordionGridRenderer;
	import org.farmcode.display.containers.accordionGrid.AccordionGridView;
	import org.farmcode.display.containers.grid.GridView;
	import org.farmcode.display.controls.BufferBar;
	import org.farmcode.display.controls.ScrollButtons;
	import org.farmcode.display.controls.Slider;
	import org.farmcode.display.controls.SliderButton;
	import org.farmcode.display.controls.TextInput;
	import org.farmcode.display.controls.TextLabelButton;
	import org.farmcode.display.controls.popout.DropDownList;
	import org.farmcode.display.controls.popout.PopoutDisplay;
	import org.farmcode.display.controls.popout.PopoutList;
	import org.farmcode.display.controls.toolTip.ToolTipAnnotator;
	import org.farmcode.display.controls.toolTip.ToolTipDisplay;
	import org.farmcode.display.controls.toolTip.ToolTipManager;
	import org.farmcode.display.core.View;
	import org.farmcode.display.layout.AbstractLayout;
	import org.farmcode.display.layout.ProxyLayoutSubject;
	import org.farmcode.display.layout.accordion.AccordionLayout;
	import org.farmcode.display.layout.canvas.CanvasLayout;
	import org.farmcode.display.layout.frame.FrameLayout;
	import org.farmcode.display.layout.grid.AbstractGridLayout;
	import org.farmcode.display.layout.grid.GridLayout;
	import org.farmcode.display.layout.grid.RendererGridLayout;
	import org.farmcode.display.layout.list.ListLayout;
	import org.farmcode.display.layout.relative.RelativeLayout;
	import org.farmcode.display.layout.stage.StageFillLayout;
	import org.farmcode.display.parallax.modifiers.ParallaxCamera;
	import org.farmcode.display.popup.PopupInfo;
	import org.farmcode.display.progress.AbstractProgressDisplay;
	import org.farmcode.display.progress.SWFPreloaderFrame;
	import org.farmcode.display.progress.SimpleProgressDisplay;
	import org.farmcode.display.transition.BlurTransition;
	import org.farmcode.display.transition.CrossFadeTransition;
	import org.farmcode.display.transition.ExposureTransition;
	import org.farmcode.display.transition.IrisTransition;
	import org.farmcode.display.transition.ShutterTransition;
	import org.farmcode.display.transition.Transition;
	import org.farmcode.display.transition.WipeTransition;
	import org.farmcode.display.utils.TopLayerManager;
	import org.farmcode.media.MediaProgressDisplayAdaptor;
	import org.farmcode.media.image.ImageSource;
	import org.farmcode.media.video.ProgressiveVideoSource;
	import org.farmcode.media.video.StreamingVideoSource;
	import org.farmcode.media.video.VolumeMemory;
	import org.farmcode.sound.soundControls.CompositeSoundControl;
	import org.farmcode.sound.soundControls.IntroOutroSoundControl;
	import org.farmcode.sound.soundControls.SoundControl;
	import org.farmcode.sound.soundControls.SoundTransformControl;
	import org.farmcode.utils.DateFormat;

	public class TestInclude
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
			PopupInfo;
			ErrorPopupActor;
			SocketCollectionContainer;
			PopupActor;
			TextLabelPlug;
			TransitionActor;
			ProgressIndicatorActor;
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
			ScrollWrapper;
			ScrollButtons;
			ImageSource;
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
			GridView;
		}
	}
}