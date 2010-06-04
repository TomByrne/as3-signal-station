package org.farmcode.sodalityPlatformEngine.parallax.adviceTypes
{
	import org.farmcode.sodality.advice.IAdvice;
	import org.farmcode.sodalityPlatformEngine.parallax.CameraSettings;

	public interface IChangeCameraSettingsAdvice extends IAdvice
	{
		function get cameraSettings(): CameraSettings;
	}
}