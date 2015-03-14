package cc.hl.view.video {
	import flash.events.*;
	import org.puremvc.as3.interfaces.*;
	import org.puremvc.as3.patterns.mediator.*;
	import cc.hl.model.video.*;

	public class VideoMediator extends Mediator implements IMediator{
		public function VideoMediator(obj:Object){
			super("VideoMediator", obj);
			this.addListener();
		}

		override public function listNotificationInterests() : Array {
			return [
					Order.Video_Start_Request,
					Order.Video_Play_Request,
					Order.Video_Pause_Request,
					Order.Video_Seek_Request,
					Order.Video_Volume_Request,
					Order.On_Resize
				];
		}

		override public function handleNotification(notify:INotification) : void{
			switch(notify.getName()){
				case Order.Video_Start_Request:
					this.onStartVideo(notify.getBody());
					break;
				case Order.Video_Play_Request:
					this.videoView.provider.playing = true;
					break;
				case Order.Video_Pause_Request:
					this.videoView.provider.playing = false;
					break;
				case Order.Video_Seek_Request:
					this.onSeekTime(notify.getBody());
					break;
				case Order.Video_Volume_Request:
					this.videoView.provider.volume = notify.getBody().volume;
					break;
				case Order.On_Resize:
					this.onResize(notify.getBody());
					break;
			}
		}

		protected function addListener():void{
			if(!this.videoView.hasEventListener("VIDEO_PROVIDER_INIT")){
				this.videoView.addEventListener("VIDEO_PROVIDER_INIT", this.onVideoInit);
				this.videoView.addEventListener("VIDEO_PROVIDER_UPDATE", this.onVideoUpdate);
			}
		}

		protected function onStartVideo(obj:Object) : void {
			if(this.videoView.parent == null){
				GlobalData.VIDEO_LAYER.addChild(this.videoView);
			}
			this.videoView.startVideo(obj.vid, obj.type, obj.startTime);
		}

		protected function onVideoInit(event:Event):void{
			sendNotification(Order.ControlBar_VideoInfo_Request, {"videoSeconds":this.videoView.provider.videoLength});
		}

		protected function onVideoUpdate(event:Event):void{
			sendNotification(Order.ControlBar_Update_Request, 
				{
					"playedSeconds"	:this.videoView.provider.time,
					"videoSeconds"	:this.videoView.provider.videoLength
				});
		}

		protected function onSeekTime(obj:Object):void{
			this.videoView.provider.time = obj.seekTime;
		}

		protected function onResize(obj:Object):void{
			this.videoView.resize(obj.w, obj.h);
		}

		protected function get videoView() : VideoView {
			return viewComponent as VideoView;
		}			
	}
}