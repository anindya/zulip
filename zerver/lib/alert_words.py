from __future__ import absolute_import

from django.db.models import Q
import zerver.models
from zerver.lib.cache import cache_with_key, realm_alert_words_cache_key
import ujson
import six

@cache_with_key(realm_alert_words_cache_key, timeout=3600*24)
def alert_words_in_realm(realm):
    users_query = zerver.models.UserProfile.objects.filter(realm=realm, is_active=True)
    alert_word_data = users_query.filter(~Q(alert_words=ujson.dumps([]))).values('id', 'alert_words')
    all_user_words = dict((elt['id'], ujson.loads(elt['alert_words'])) for elt in alert_word_data)
    user_ids_with_words = dict((user_id, w) for (user_id, w) in six.iteritems(all_user_words) if len(w))
    return user_ids_with_words

def user_alert_words(user_profile):
    return ujson.loads(user_profile.alert_words)

def add_user_alert_words(user_profile, alert_words):
    words = user_alert_words(user_profile)

    new_words = [w for w in alert_words if not w in words]
    words.extend(new_words)

    set_user_alert_words(user_profile, words)

    return words

def remove_user_alert_words(user_profile, alert_words):
    words = user_alert_words(user_profile)
    words = [w for w in words if not w in alert_words]

    set_user_alert_words(user_profile, words)

    return words

def set_user_alert_words(user_profile, alert_words):
    user_profile.alert_words = ujson.dumps(alert_words)
    user_profile.save(update_fields=['alert_words'])
