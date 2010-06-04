package org.farmcode.sodalityPlatformEngine.control
{
	import org.farmcode.sodalityLibrary.control.IControllable;
	import org.farmcode.sodalityLibrary.control.members.*;
	
	public interface IPlatformControllable extends IControllable
	{
		function get cameraXControl():ProxyPropertyMember;
		function get cameraYControl():ProxyPropertyMember;
		function get cameraZControl():ProxyPropertyMember;
	}
}