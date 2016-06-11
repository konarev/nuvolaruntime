/*
 * Copyright 2014-2015 Jiří Janoušek <janousek.jiri@gmail.com>
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met: 
 * 
 * 1. Redistributions of source code must retain the above copyright notice, this
 *    list of conditions and the following disclaimer. 
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution. 
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
 * ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

using Diorite;

public class Nuvola.MediaPlayerBinding: ModelBinding<MediaPlayerModel>
{
	public MediaPlayerBinding(Drt.ApiRouter server, WebWorker web_worker, MediaPlayerModel model)
	{
		base(server, web_worker, "Nuvola.MediaPlayer", model);
	}
	
	protected override void bind_methods()
	{
		bind("setFlag", "(sb)", handle_set_flag);
		bind("setTrackInfo", "(@a{smv})", handle_set_track_info);
		bind("getTrackInfo", null, handle_get_track_info);
		model.set_rating.connect(on_set_rating);
	}
	
	private Variant? handle_set_track_info(GLib.Object source, Variant? data) throws Diorite.MessageError
	{
		check_not_empty();
		Variant dict;
		data.get("(@a{smv})", out dict);
		var title = variant_dict_str(dict, "title");
		var artist = variant_dict_str(dict, "artist");
		var album = variant_dict_str(dict, "album");
		var state = variant_dict_str(dict, "state");
		var artwork_location = variant_dict_str(dict, "artworkLocation");
		var artwork_file = variant_dict_str(dict, "artworkFile");
		var rating = variant_dict_double(dict, "rating", 0.0);
		model.set_track_info(title, artist, album, state, artwork_location, artwork_file, rating);
		
		SList<string> playback_actions = null;
		var actions = Diorite.variant_to_strv(dict.lookup_value("playbackActions", null).get_maybe().get_variant());
		foreach (var action in actions)
			playback_actions.prepend(action);
		
		playback_actions.reverse();
		model.playback_actions = (owned) playback_actions;
		return new Variant.boolean(true);
	}
	
	private Variant? handle_get_track_info(GLib.Object source, Variant? data) throws Diorite.MessageError
	{
		check_not_empty();
		var builder = new VariantBuilder(new VariantType("a{smv}"));
		builder.add("{smv}", "title", Drt.new_variant_string_or_null(model.title));
		builder.add("{smv}", "artist", Drt.new_variant_string_or_null(model.artist));
		builder.add("{smv}", "album", Drt.new_variant_string_or_null(model.album));
		builder.add("{smv}", "state", Drt.new_variant_string_or_null(model.state));
		builder.add("{smv}", "artworkLocation", Drt.new_variant_string_or_null(model.artwork_location));
		builder.add("{smv}", "artworkFile", Drt.new_variant_string_or_null(model.artwork_file));
		builder.add("{smv}", "rating", new Variant.double(model.rating));
		return builder.end();
	}
	
	private Variant? handle_set_flag(GLib.Object source, Variant? data) throws Diorite.MessageError
	{
		check_not_empty();
		bool handled = false;
		string name;
		bool val;
		data.get("(sb)", out name, out val);
		switch (name)
		{
		case "can-go-next":
		case "can-go-previous":
		case "can-play":
		case "can-pause":
		case "can-stop":
		case "can-rate":
			handled = true;
			GLib.Value value = GLib.Value(typeof(bool));
			value.set_boolean(val);
			model.@set_property(name, value);
			break;
		default:
			critical("Unknown flag '%s'", name);
			break;
		}
		return new Variant.boolean(handled);
	}
	
	private void on_set_rating(double rating)
	{
		if (!model.can_rate)
		{
			warning("Rating is not enabled");
			return;
		}
		
		try
		{
			var payload = new Variant("(sd)", "RatingSet", rating);
			call_web_worker("Nuvola.mediaPlayer.emit", ref payload);
		}
		catch (GLib.Error e)
		{
			warning("Communication failed: %s", e.message);
		}
	}
}
