package cc.hl.model.video.interfaces {
	
	/**
	 *
	 * 管理视频码流NetStream的容器，
	 * @author xy
	 * @Time 2015-3-4
	 *
	**/
	public interface IVideoProvider{

		/**
		 *
		 * 从指定位置开始播发视频源
		 * @param	startTime:视频开始播放的时间
		 * @return	void
		 *
		**/
		function start(startTime:Number=0):void;
		function getVideoInfo():String;
		function resize(w:Number, h:Number):void;


		function get playing():Boolean;
		function set playing(state:Boolean):void;
		function get volume():Number;
		function set volume(state:Number):void;
		function get time():Number;
		function set time(t:Number):void;
		function get streamTime():Number;
		function get buffPercent():Number;
		function get buffering():Boolean;
		function get videoLength():Number;
	}
}