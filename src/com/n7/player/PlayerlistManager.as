package com.n7.player{
	
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	
	public class PlayerlistManager extends EventDispatcher{
		
		private var _xml:XML;
		private var _playlist:Array;
		private var _shufflelist:Array;
		private var _shuffle:Boolean = false;
		private var _currentNumber:Number = 0;
		private var _thisTrack:PlayerTrack;
		private var _playlistURL:String="";					
		
		public function PlayerlistManager(playlistURL:String = ""):void{
			_playlist = new Array();
			_shufflelist = new Array();
			if(playlistURL!=""){
				_playlistURL = playlistURL;
				loadPlaylist(_playlistURL);
			}
		}
		private function get playlist():Array{
			if(!_shuffle){
				return _playlist;
			}
			else{
				return _shufflelist;
			}
		}
		public function get length():int{
			return _playlist.length;
		}
		private function set playlist(list:Array):void{
			_playlist = new Array();
			var teller:Number=0;
			for (var i:uint = 0;i<list.length;i++){
				if(PlayerTrack(list[i]).file!=""){
					teller++;
					var song:PlayerTrack = new PlayerTrack();
					song.title = PlayerTrack(list[i]).title;
					song.artist = PlayerTrack(list[i]).artist;
					song.album = PlayerTrack(list[i]).album;
					song.file = PlayerTrack(list[i]).file;
					song.totalSeconds = PlayerTrack(list[i]).totalSeconds;
					song.trackNumber = teller;
					_playlist.push(song);
				}
				else{
					dispatchEvent(new PlayerInternalEvent(PlayerInternalEvent.TRACK_NOT_ADDED_TO_PLAYLIST));
				}
			}
			createShuffleList();
			dispatchEvent(new PlayerInternalEvent(PlayerInternalEvent.PLAYLIST_LOADED));
			gotoFirstTrack();
		}
		public function moveTrackTo(trackNumber:Number,destination:Number):Boolean{
			var theTrack:PlayerTrack;
			if(trackNumber-1 <= _playlist.length && trackNumber != 0 && destination !=0){
				theTrack = PlayerTrack(_playlist[trackNumber-1]).copy();
				_playlist.splice(trackNumber-1,1);
				_playlist.splice(destination-1,0,theTrack);
				cleanUpTrackNumbers();
				return true;
			}
			else{
				return false;
			}
		}
		public function gotoNextTrack():void{
			_currentNumber++;
			if(_currentNumber == _playlist.length){
				_currentNumber = 0;
			}
			loadCurrentTrack();
		}
		public function removeTrack(trackNumber:Number):Boolean{
			if(getCurrentTrack().trackNumber == trackNumber){
				dispatchEvent(new PlayerInternalEvent(PlayerInternalEvent.CURRENT_TRACK_TO_BE_REMOVED));
			}
			for(var i:uint=0;i<_playlist.length;i++){
				if(PlayerTrack(_playlist[i]).trackNumber == trackNumber){
					_playlist.splice(i,1);
					cleanUpTrackNumbers();
					createShuffleList();
					return true;
				}
			}
			return false; 					
		}
		public function get totalTracks():Number{
			return _playlist.length;
		}
		public function get currentTrackNumber():Number{
			return _currentNumber+1;
		}
		private function cleanUpTrackNumbers():void{
			for(var i:uint=0;i<_playlist.length;i++){
				PlayerTrack(_playlist[i]).trackNumber = i+1;
			}
		}
		public function gotoPreviousTrack():void{
			_currentNumber--;
			if(_currentNumber == -1){
				_currentNumber = _playlist.length-1;
			}
			loadCurrentTrack();
		}
		private function loadCurrentTrack():void{
			if(!_shuffle){
				_thisTrack = _playlist[_currentNumber];
			}
			else{
				_thisTrack = _shufflelist[_currentNumber];
			}
		}
		
		public function addTrack(track:PlayerTrack):Boolean{
			if(track.file!=''){
				if(_playlist==null){
					_playlist = new Array();
				}
				_playlist.push(track);
				cleanUpTrackNumbers();
				createShuffleList();
				dispatchEvent(new PlayerInternalEvent(PlayerInternalEvent.TRACK_ADDED_TO_PLAYLIST));
				return true;
			}
			else{
				return false;
			}
			
		}
		public function loadPlaylist(xmlPath:String):void{
			var urlloader:URLLoader = new URLLoader();
			urlloader.addEventListener(Event.COMPLETE, playlistLoaded);
			urlloader.addEventListener(IOErrorEvent.IO_ERROR,playListioErrorHandler);
			urlloader.load(new URLRequest(xmlPath+'?c='+Math.random()));
		}
		private function playListioErrorHandler(e:IOErrorEvent):void{
			dispatchEvent(new PlayerInternalEvent(PlayerInternalEvent.PLAYLIST_STREAM_ERROR));
		}
		public function gotoFirstTrack():void{
			if(!_shuffle){
				_thisTrack = _playlist[0];
			}
			else{
				_thisTrack = _shufflelist[0];
			}
		}
		public function getCurrentTrack():PlayerTrack{
			return _thisTrack;
		}
		public function setShuffle(value:Boolean):Boolean{
			if(_shuffle != value){
				_shuffle = value;
				return true;
			}
			else{
				return false;
			}
		}
		private function playlistLoaded(e:Event):void{
			try{
				_xml = XML(e.target.data);
			}
			catch(e:TypeError){
				dispatchEvent(new PlayerInternalEvent(PlayerInternalEvent.PLAYLIST_INVALID_XML));
				return ;
			}
			_playlist = new Array();
			for (var i:uint = 0;i<_xml.track.length();i++){
				if(_xml.track[i].filename !=""){
					var song:PlayerTrack = new PlayerTrack();
					song.title = _xml.track[i].title;
					song.artist = _xml.track[i].artist;
					song.album = _xml.track[i].album;
					song.file = _xml.track[i].filename;
					song.totalSeconds = _xml.track[i].totalTime;
					song.trackNumber = i+1;
					_playlist.push(song);
				}
				else{
					dispatchEvent(new PlayerInternalEvent(PlayerInternalEvent.TRACK_NOT_ADDED_TO_PLAYLIST));
				}
			}
			createShuffleList();
			dispatchEvent(new PlayerInternalEvent(PlayerInternalEvent.PLAYLIST_LOADED));
		}
		private function createShuffleList():void{
			_shufflelist = new Array();
			var temp:Array = new Array();
			for (var s:Number=0;s<_playlist.length;s++){
				temp.push(PlayerTrack(_playlist[s]).copy());
			}
			var teller:Number =0;
			while(temp.length !=0){
				teller++;
				var next:Number = Math.floor(Math.random()*temp.length);
				var theTrack:PlayerTrack = PlayerTrack(temp[next]);
				theTrack.trackNumber = teller;
				_shufflelist.push(theTrack);
				temp.splice(next,1);
			}
		}
		public function gotoTrack(trackNumber:Number):void{
			if(!(trackNumber < 0) && !(trackNumber > _playlist.length)){
				_currentNumber = trackNumber-1;
				loadCurrentTrack();
			}
			else{
				dispatchEvent(new PlayerInternalEvent(PlayerInternalEvent.PLAYLIST_TRACK_OUT_OF_BOUNDS));
			}
		}
		public function toArray():Array{
			return playlist;
		}
		
		public function getTracksInfo():Array {
			var tracksInfo:Array = new Array();
			
			for (var s:Number=0;s<_playlist.length;s++){
				tracksInfo.push({
					"Artiste": _playlist[s].artist,
					"Title": _playlist[s].title,
					"Album": _playlist[s].album
				});
			}
			return tracksInfo;	
		}
	}
}