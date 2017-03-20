<?php
/**
 * BEdita, API-first content management framework
 * Copyright 2017 ChannelWeb Srl, Chialab Srl
 *
 * This file is part of BEdita: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published
 * by the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * See LICENSE.LGPL or <http://gnu.org/licenses/lgpl-3.0.html> for more details.
 */

namespace BEdita\Core\Model\Validation;

use Cake\Validation\Validator;

/**
 * Base validator for BEdita objects.
 *
 * @since 4.0.0
 */
class ObjectsValidator extends Validator
{

    /**
     * {@inheritDoc}
     */
    public function __construct()
    {
        parent::__construct();

        $this
            ->naturalNumber('id')
            ->allowEmpty('id', 'create')
            ->requirePresence('id', 'update')

            ->inList('status', ['on', 'off', 'draft'])
            ->notEmpty('status')

            ->ascii('uname')
            ->notEmpty('uname')
            ->add('uname', 'unique', ['rule' => 'validateUnique', 'provider' => 'table'])

            ->boolean('locked')
            ->allowEmpty('locked')

            ->boolean('deleted')
            ->allowEmpty('deleted')

            ->dateTime('published')
            ->allowEmpty('published')

            ->allowEmpty('title')

            ->allowEmpty('description')

            ->allowEmpty('body')

            ->allowEmpty('extra')

            ->allowEmpty('lang')

            ->dateTime('publish_start')
            ->allowEmpty('publish_start')

            ->dateTime('publish_end')
            ->allowEmpty('publish_end');
    }
}
